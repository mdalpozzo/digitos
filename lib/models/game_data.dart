class GameData {
  final int? best;
  final String? displayName;
  final List<String> gamesSeen;
  final List<String> gamesCompleted;
  final String uuid;

  GameData({
    this.best,
    this.displayName,
    this.gamesSeen = const [],
    this.gamesCompleted = const [],
    required this.uuid,
  });

  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      best: json['best'],
      displayName: json['display_name'],
      gamesSeen: json['games_seen'],
      gamesCompleted: json['games_completed'],
      uuid: json['uuid'],
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
