import 'package:digitos/audio/audio_controller.dart';
import 'package:digitos/audio/sounds.dart';
import 'package:digitos/services/app_logger.dart';
import 'package:digitos/view_models/game_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LevelConfigItem {
  final String name;
  final Color color;

  LevelConfigItem({
    required this.name,
    required this.color,
  });
}

class LevelButton extends StatelessWidget {
  const LevelButton({
    super.key,
    required this.level,
  });

  static final _log = AppLogger('LevelButton');

  final int level;

  static Map<int, LevelConfigItem> levelsDisplayConfig = {
    1: LevelConfigItem(name: 'easy', color: Colors.green),
    2: LevelConfigItem(name: 'medium', color: Colors.orange),
    3: LevelConfigItem(name: 'hard', color: Colors.red),
    4: LevelConfigItem(name: 'expert', color: Colors.pink),
  };

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();
    final gameViewModel = Provider.of<GameViewModel>(context);

    LevelConfigItem? levelConfig = levelsDisplayConfig[level];

    return InkWell(
      onTap: () async {
        _log.info('level $level selected');
        audioController.playSfx(SfxType.buttonTap);

        // todo think about this for performance... some kind of loading animation or something? when should it actually fetch the data, now or loading state on game screen?
        gameViewModel.onPressLevelButton(difficulty: level).then((_) {
          GoRouter.of(context).go('/game');
        });
      },
      child: Column(
        children: [
          Text(
            level.toString(),
            style: TextStyle(
              fontFamily: 'Permanent Marker',
              fontSize: 60,
              height: 1,
              color: levelConfig?.color ?? Colors.black,
            ),
          ),
          Text(
            levelConfig?.name ?? 'unknown',
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
