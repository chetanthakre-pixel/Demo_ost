import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import '../models/api_error.dart';
import 'config.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

// Provide the CookieJar asynchronously
final cookieJarProvider = FutureProvider<CookieJar>((ref) async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final appDocPath = appDocDir.path;
  return PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage("$appDocPath/.cookies/"),
  );
});

final apiClientProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  // Default to a memory CookieJar until the async one loads
  final cookieJar = ref.watch(cookieJarProvider).value ?? CookieJar();
  return ApiClient(storage, cookieJar);
});

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;
  final CookieJar _cookieJar;
  final VoidCallback? onUnauthorized;

  ApiClient(this._storage, this._cookieJar, {this.onUnauthorized}) {
    _dio = Dio(BaseOptions(
      baseUrl: Config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    _dio.interceptors.add(CookieManager(_cookieJar));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Still send the JWT from secure storage if we have one (for backwards compatibility/testing)
        final token = await _storage.read(key: 'jwt');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.data is Map<String, dynamic> && response.data.containsKey('data')) {
          response.data = response.data['data'];
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          if (errorData.containsKey('error')) {
            final apiError = ApiException.fromJson(errorData);
            if (apiError.code == 'UNAUTHORIZED' && onUnauthorized != null) {
              onUnauthorized!();
            }
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                response: e.response,
                type: e.type,
                error: apiError,
                message: apiError.message,
              ),
            );
          }
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return response.data;
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    final response = await _dio.post(path, data: data);
    return response.data;
  }
}
