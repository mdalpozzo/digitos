import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/auth_service/auth_service.dart';

class UserSessionManager {
  final AuthService authService;
  final AccountService accountService;

  UserSessionManager({
    required this.authService,
    required this.accountService,
  });

  Future<void> handleLogin(String email, String password) async {
    // Use AuthService to login
    await authService.loginUser(email, password);
  }

  // more methods here to handle logout, account creation, etc.
}
