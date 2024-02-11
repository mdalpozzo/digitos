import 'package:digitos/service_locator.dart';
import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

// This widget is used to wrap the entire app and handle the creation of an
// anonymous user if no user is currently logged in
class AuthAppWrapper extends StatefulWidget {
  final Widget child;

  const AuthAppWrapper({required this.child, super.key});

  @override
  _AuthAppWrapperState createState() => _AuthAppWrapperState();
}

class _AuthAppWrapperState extends State<AuthAppWrapper> {
  static final _log = Logger('AuthAppWrapper');

  @override
  void initState() {
    super.initState();

    // Defer the execution until after the build phase
    Future.microtask(() async {
      // TODO logic that utilizes the accountService and authService should be moved to a ViewModel
      final authService = ServiceLocator.get<AuthService>();
      final accountService = ServiceLocator.get<AccountService>();

      // Automatically create an anonymous user if no user is currently logged in
      UserCredential userCred = await authService.signInAnonymously();
      String? userId = userCred.user?.uid;

      if (userId != null) {
        _log.info('initState: Anonymous user ID: $userId');
        await accountService.createNewAccountInDB(
          userId,
          isAnonymous: true,
        );
      } else {
        _log.severe(
            'initState: Anonymous user ID is null, could not create anonymous user data');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
