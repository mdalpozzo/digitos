import 'package:digitos/view_models/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void showDisplayNameDialog(BuildContext context) {
  showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          DisplayNameDialog(animation: animation));
}

class DisplayNameDialog extends StatefulWidget {
  final Animation<double> animation;

  const DisplayNameDialog({required this.animation, super.key});

  @override
  State<DisplayNameDialog> createState() => _DisplayNameDialogState();
}

class _DisplayNameDialogState extends State<DisplayNameDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: widget.animation,
        curve: Curves.easeOutCubic,
      ),
      child: SimpleDialog(
        title: const Text('Change name'),
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 12,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            // onChanged: (value) {
            //   context.read<AccountService>().updateDisplayName(value);
            // },
            onSubmitted: (value) async {
              // TODO handle error try/catch

              // Player tapped 'Submit'/'Done' on their keyboard.
              await context.read<SettingsViewModel>().setDisplayName(value);

              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<SettingsViewModel>().displayName ?? '';
  }
}
