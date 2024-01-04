import 'package:digitos/utils/getRandomSuccessPhrase.dart';
import 'package:flutter/material.dart';

class SuccessModal extends StatelessWidget {
  const SuccessModal({
    super.key,
    required this.onConfirm,
    required this.numberOfMoves,
  });

  final void Function() onConfirm;
  final int numberOfMoves;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Text(
          getRandomSuccessPhrase(),
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        Text(
          'Solved in ${numberOfMoves.toString()} moves',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onConfirm,
          child: const Text('Another puzzle'),
        ),
      ],
    );
  }
}
