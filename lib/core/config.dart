// lib/core/config.dart

class Config {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );

  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: false,
  );

  static String get wsUrl {
    if (apiBaseUrl.startsWith('https')) {
      return apiBaseUrl.replaceFirst('https', 'wss').replaceFirst('/api', '/ws');
    } else {
      return apiBaseUrl.replaceFirst('http', 'ws').replaceFirst('/api', '/ws');
    }
  }
}
