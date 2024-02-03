import 'package:digitos/audio/audio_controller.dart';
import 'package:digitos/audio/sounds.dart';
import 'package:digitos/screens/game_screen/game_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LevelButton extends StatelessWidget {
  const LevelButton({
    super.key,
    required this.level,
  });

  final int level;

  static const Map<int, String> levelNames = {
    1: 'easy',
    2: 'medium',
    3: 'hard',
    4: 'expert',
  };

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();
    final gameViewModel = Provider.of<GameViewModel>(context);

    return InkWell(
      onTap: () {
        audioController.playSfx(SfxType.buttonTap);

        // todo think about this for performance... some kind of loading animation or something? when should it actually fetch the data, now or loading state on game screen?
        gameViewModel.startNewGame();

        GoRouter.of(context).go('/game');
      },
      child: Column(
        children: [
          // Container(
          //   width: 100, // Adjust the size as needed
          //   height: 100, // Adjust the size as needed
          //   decoration: BoxDecoration(
          //     color: Colors.blue,
          //     shape: BoxShape.circle,
          //   ),
          //   child: Icon(
          //     Icons.play_arrow,
          //     size: 50,
          //     color: Colors.white,
          //   ),
          // ),
          Text(
            level.toString(),
            style: TextStyle(
              fontFamily: 'Permanent Marker',
              fontSize: 60,
              height: 1,
            ),
          ),
          Text(
            levelNames[level] ?? 'unknown',
            style: TextStyle(
              fontFamily: 'Permanent Marker',
              fontSize: 26,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
