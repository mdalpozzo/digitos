import 'package:digitos/audio/audio_controller.dart';
import 'package:digitos/audio/sounds.dart';
import 'package:digitos/screens/game_screen/game_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DailyButton extends StatelessWidget {
  const DailyButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();
    final gameViewModel = Provider.of<GameViewModel>(context);

    return InkWell(
      onTap: () {
        audioController.playSfx(SfxType.buttonTap);

        gameViewModel.setPuzzleToDaily();

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
