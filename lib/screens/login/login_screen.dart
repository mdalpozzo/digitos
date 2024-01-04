import 'package:digitos/users/user_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showEmailError = false;
  bool _showPasswordError = false;

  @override
  Widget build(BuildContext context) {
    final userSessionManager =
        Provider.of<UserSessionManager>(context, listen: false);

    return Scaffold(
      backgroundColor: Color(0xFFE6E6FA), // Pastel lavender background color
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Log In',
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 30,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _showEmailError ? 'Email must be provided' : null,
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                if (_showEmailError) {
                  setState(() {
                    _showEmailError = false;
                  });
                }
              },
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText:
                    _showPasswordError ? 'Password must be provided' : null,
              ),
              obscureText: true,
              onChanged: (value) {
                if (_showPasswordError) {
                  setState(() {
                    _showPasswordError = false;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).go('/');
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String email = _emailController.text.trim();
                    String password = _passwordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      if (email.isEmpty) {
                        setState(() {
                          _showEmailError = email.isEmpty;
                        });
                      }
                      if (password.isEmpty) {
                        setState(() {
                          _showPasswordError = password.isEmpty;
                        });
                      }
                      return;
                    }

                    if (email.isNotEmpty && password.isNotEmpty) {
                      try {
                        await userSessionManager.handleLogin(email, password);

                        // TODO display confetti and transition to home screen
                        // Check if the widget is still mounted before calling setState or navigating
                        if (mounted) {
                          // TODO display confetti and transition to home screen
                          GoRouter.of(context).go('/');
                        }
                      } catch (e) {
                        // TODO Handle login errors or show error messages
                      }
                    }
                  },
                  child: Text('Login'),
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Text('Don\'t have an account?'),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/register');
              },
              child: Text('Register'),
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
