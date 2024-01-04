class CompletedGameData {
  final String puzzleId;
  final int moves;
  final DateTime completedAt;
  // final int? time;

  CompletedGameData({
    required this.puzzleId,
    required this.moves,
    required this.completedAt,
    // this.time,
  });

  factory CompletedGameData.fromJson(Map<String, dynamic> json) {
    return CompletedGameData(
      puzzleId: json['puzzle_id'],
      moves: json['moves'],
      completedAt: DateTime.parse(json['completed_at']),
      // time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'puzzle_id': puzzleId,
      'moves': moves,
      'completed_at': completedAt.toIso8601String(),
      // 'time': time,
    };
  }
}

class GameData {
  final int? best;
  final String? displayName;
  final List<String> gamesSeen;
  final List<CompletedGameData> gamesCompleted;
  // final String uuid;

  GameData({
    this.best,
    this.displayName,
    this.gamesSeen = const [],
    this.gamesCompleted = const [],
    // required this.uuid,
  });

  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      best: json['best'],
      displayName: json['display_name'],
      gamesSeen: json['games_seen'],
      gamesCompleted: json['games_completed'],
      // uuid: json['uuid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'best': best,
      'games_seen': gamesSeen,
      'games_completed': gamesCompleted,
      'display_name': displayName,
      // 'uuid': uuid,
    };
  }
}
