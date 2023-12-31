import 'package:flutter/material.dart';

class SuccessModal extends StatelessWidget {
  const SuccessModal({super.key, required this.onConfirm});

  final void Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        const Text('Congratulations, you solved it!'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onConfirm,
          child: const Text('Play again.'),
        ),
      ],
    );
  }
}
