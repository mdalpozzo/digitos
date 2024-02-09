class AppException implements Exception {
  final String message;
  final String code;
  final String? module;

  AppException({
    required this.message,
    required this.code,
    this.module,
  });

  @override
  String toString() => 'AppException in $module: $message (Code: $code)';
}
