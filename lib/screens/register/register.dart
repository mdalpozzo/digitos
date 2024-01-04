import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _log = Logger('_RegisterScreenState');

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final accountService = Provider.of<AccountService>(context, listen: false);

    return Scaffold(
      // appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Create an account',
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 30,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String email = _emailController.text.trim();
                    String password = _passwordController.text.trim();
                    if (email.isNotEmpty && password.isNotEmpty) {
                      try {
                        var oldUserId = authService.currentUser?.uid;

                        await authService.createAccount(email, password);

                        var newUserId = authService.currentUser?.uid;

                        if (newUserId != null) {
                          // sync anonymous game data
                          await accountService
                              .transferGameDataToPermanentAccount(newUserId, oldUserId);
                        } else {
                          // TODO handle can't sync anonymous game data error
                          _log.warning(
                              'New user id is null. Unable to sync anonymous game data.');
                        }

                        // Check if the widget is still mounted before calling setState or navigating
                        if (mounted) {
                          // TODO display confetti and transition to home screen
                          GoRouter.of(context).go('/');
                        }
                        // TODO Handle successful registration
                      } catch (e) {
                        // TODO Handle errors or show error messages
                      }
                    }
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
