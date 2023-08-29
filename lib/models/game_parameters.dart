class GameParameters {
  final int targetNumber;
  final List<int> initialNumbers;
  final int difficulty;

  GameParameters({
    required this.targetNumber,
    required this.initialNumbers,
    required this.difficulty,
  });

  factory GameParameters.fromJson(Map<String, dynamic> json) {
    List<int> initialNumbers = List<int>.from(json['initial_numbers']);
    return GameParameters(
      targetNumber: json['target_number'],
      initialNumbers: initialNumbers,
      difficulty: json['difficulty'],
    );
  }
}
