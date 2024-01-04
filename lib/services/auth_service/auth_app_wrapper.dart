import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class AuthAppWrapper extends StatefulWidget {
  final Widget child;

  AuthAppWrapper({required this.child});

  @override
  _AuthAppWrapperState createState() => _AuthAppWrapperState();
}

class _AuthAppWrapperState extends State<AuthAppWrapper> {
  static final _log = Logger('AuthAppWrapper');

  @override
  void initState() {
    super.initState();

    // Defer the execution until after the build phase
    Future.microtask(() {
      final authService = Provider.of<AuthService>(context, listen: false);
      final accountService =
          Provider.of<AccountService>(context, listen: false);

      // Automatically create an anonymous user if no user is currently logged in
      authService.signInAnonymously();

      // Listen to authentication state changes
      authService.onAuthChanges.listen((user) {
        if (user != null) {
          if (!user.isAnonymous) {
            _log.info('Auth state changed: User logged in: ${user.toString()}');
            // Handle the transition of game data here
            accountService.transferGameDataToPermanentAccount(user.uid);
          } else {
            _log.info(
                'Auth state changed: Anonymous user logged in: ${user.toString()}');
          }
        } else {
          _log.info('Auth state changed: User logged out');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
