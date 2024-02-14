import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/app_logger.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterViewModel with ChangeNotifier {
  final AccountService accountService;
  final AuthService authService;
  static final _log = AppLogger('RegisterViewModel');

  RegisterViewModel({
    required this.accountService,
    required this.authService,
  });

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      var oldUserId = authService.currentUser?.uid;

      UserCredential userCred =
          await authService.createAccount(email, password);
      String? userId = userCred.user?.uid;

      if (userId == null) {
        // TODO handle error
        _log.severe('User ID is null. Unable to create account.');
        return;
      }

      await accountService.createNewAccountInDB(userId);

      var newUserId = authService.currentUser?.uid;

      if (newUserId != null) {
        // sync anonymous game data
        await accountService.transferGameDataToPermanentAccount(
          newUserId,
          oldUserId,
        );
      } else {
        // TODO handle can't sync anonymous game data error
        _log.warning(
            'New user id is null. Unable to sync anonymous game data.');
      }

      _log.info('User registered successfully');
    } catch (e) {
      // TODO Handle errors or show error messages
      _log.severe('Error registering user: $e');

      rethrow;
    }
  }
}
