import 'package:digitos/services/account_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UpdateDisplayNameScreen extends StatefulWidget {
  const UpdateDisplayNameScreen({super.key});

  @override
  State<UpdateDisplayNameScreen> createState() => _UpdateDisplayNameScreenState();
}

class _UpdateDisplayNameScreenState extends State<UpdateDisplayNameScreen> {
  final _usernameController = TextEditingController();
  bool _isUpdating = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final accountService = Provider.of<AccountService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Change User Name'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'New User Name',
                errorText: _errorMessage,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUpdating
                  ? null
                  : () async {
                      setState(() {
                        _isUpdating = true;
                        _errorMessage = null;
                      });

                      try {
                        await accountService
                            .updateDisplayName(_usernameController.text.trim());

                        if (mounted) {
                          GoRouter.of(context).pop();
                        }
                      } catch (e) {
                        setState(() {
                          _errorMessage = 'Failed to update user name.';
                          _isUpdating = false;
                        });
                      }
                    },
              child: _isUpdating
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Update Name'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
