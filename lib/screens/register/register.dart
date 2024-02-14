import 'package:digitos/services/app_logger.dart';
import 'package:digitos/view_models/register_view_model.dart';
import 'package:digitos/services/auth_service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _log = AppLogger('_RegisterScreenState');

  @override
  Widget build(BuildContext context) {
    final registerViewModel =
        Provider.of<RegisterViewModel>(context, listen: false);
    BuildContext currentContext = context; // Capture the context

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
                  child: Text('Cancel'),
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Register'),
                  onPressed: () async {
                    String email = _emailController.text.trim();
                    String password = _passwordController.text.trim();

                    if (email.isNotEmpty && password.isNotEmpty) {
                      try {
                        await registerViewModel.registerWithEmailAndPassword(
                            email, password);

                        // Check if the widget is still mounted before calling setState or navigating
                        if (mounted) {
                          // TODO display confetti and transition to home screen
                          GoRouter.of(context).go('/');
                        }
                      } catch (e) {
                        // TODO Handle errors or show error messages
                        _log.severe('Error registering user: $e');

                        if (e is AuthServiceError) {
                          if (mounted) {
                            ScaffoldMessenger.of(currentContext).showSnackBar(
                              SnackBar(
                                content: Text(e.message),
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(currentContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'An error occurred. Please try again.'),
                              ),
                            );
                          }
                        }
                      }
                    }
                  },
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
