// lib/models/api_error.dart

class ApiException implements Exception {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  ApiException({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiException.fromJson(Map<String, dynamic> json) {
    // Expected format: { "error": { "code": "...", "message": "...", "details": {...} } }
    final errorJson = json['error'] as Map<String, dynamic>? ?? {};
    return ApiException(
      code: errorJson['code'] as String? ?? 'UNKNOWN_ERROR',
      message: errorJson['message'] as String? ?? 'An unexpected error occurred.',
      details: errorJson['details'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() => message;
}
