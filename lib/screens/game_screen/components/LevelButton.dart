import 'package:flutter/material.dart';

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
    required this.onPress,
  });

  final void Function() onPress;
  final int level;

  static Map<int, LevelConfigItem> levelsDisplayConfig = {
    1: LevelConfigItem(name: 'easy', color: Colors.green),
    2: LevelConfigItem(name: 'medium', color: Colors.orange),
    3: LevelConfigItem(name: 'hard', color: Colors.red),
    4: LevelConfigItem(name: 'expert', color: Colors.pink),
  };

  @override
  Widget build(BuildContext context) {
    LevelConfigItem? levelConfig = levelsDisplayConfig[level];

    return InkWell(
      onTap: onPress,
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
