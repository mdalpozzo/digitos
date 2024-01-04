import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/auth_service/auth_service.dart';

class UserSessionManager {
  final AuthService _authService;
  final AccountService _accountService;

  UserSessionManager(
    this._authService,
    this._accountService,
  );

  Future<void> handleLogin(String email, String password) async {
    // Use AuthService to login
    await _authService.loginUser(email, password);
  }

  // You can add more methods here to handle logout, account creation, etc.
}
