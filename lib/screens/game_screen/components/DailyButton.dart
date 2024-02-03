import 'package:digitos/audio/audio_controller.dart';
import 'package:digitos/audio/sounds.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DailyButton extends StatelessWidget {
  const DailyButton({
    super.key,
    required this.onConfirm,
    required this.numberOfMoves,
  });

  final void Function() onConfirm;
  final int numberOfMoves;

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();

    return InkWell(
      onTap: () {
        audioController.playSfx(SfxType.buttonTap);
        // todo setdifficulty and go to game
        GoRouter.of(context).go('/game');
      },
      child: Column(
        children: [
          Container(
            width: 100, // Adjust the size as needed
            height: 100, // Adjust the size as needed
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              size: 50,
              color: Colors.white,
            ),
          ),
          Text(
            'The Daily',
            style: TextStyle(
              fontFamily: 'Permanent Marker',
              fontSize: 30,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
