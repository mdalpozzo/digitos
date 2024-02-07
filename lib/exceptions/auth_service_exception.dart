import 'package:digitos/exceptions/app_exception.dart';

class AuthServiceException extends AppException {
  AuthServiceException({
    required super.message,
    super.code = "AUTH_ERROR",
    super.module = "AuthService",
  });
}
