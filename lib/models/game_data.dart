import 'package:cloud_firestore/cloud_firestore.dart';

class CompletedGameData {
  final String puzzleId;
  final int moves;
  final DateTime completedAt;

  CompletedGameData({
    required this.puzzleId,
    required this.moves,
    required this.completedAt,
  });

  factory CompletedGameData.fromJson(Map<String, dynamic> json) {
    return CompletedGameData(
      puzzleId: json['puzzleId'],
      moves: json['moves'],
      completedAt:
          (json['completedAt'] as Timestamp).toDate(), // Adjusted for Timestamp
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'puzzleId': puzzleId,
      'moves': moves,
      'completedAt':
          Timestamp.fromDate(completedAt), // Convert DateTime to Timestamp
    };
  }
}

class GameData {
  final int? best;
  final String? displayName;
  final List<String> gamesSeen;
  final List<CompletedGameData> gamesCompleted;

  GameData({
    this.best,
    this.displayName,
    this.gamesSeen = const [],
    this.gamesCompleted = const [],
  });

  factory GameData.fromJson(Map<String, dynamic> json) {
    var gamesCompletedFromJson = json['gamesCompleted'] as List<dynamic>? ?? [];
    var gamesCompletedList = gamesCompletedFromJson
        .map((gameDataJson) =>
            CompletedGameData.fromJson(gameDataJson as Map<String, dynamic>))
        .toList();

    return GameData(
      best: json['best'],
      displayName: json['displayName'],
      gamesSeen: List<String>.from(json['gamesSeen'] ?? []),
      gamesCompleted: gamesCompletedList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'best': best,
      'displayName': displayName,
      'gamesSeen': gamesSeen,
      'gamesCompleted': gamesCompleted.map((game) => game.toJson()).toList(),
    };
  }
}
