import 'package:digitos/models/number_option.dart';

class Puzzle {
  final String id;
  final int targetNumber;
  final List<int> initialNumbers;
  final int difficulty;

  Puzzle({
    required this.id,
    required this.targetNumber,
    required this.initialNumbers,
    required this.difficulty,
  });

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw FormatException('Missing "id" for Puzzle.');
    }
    if (json['target_number'] == null) {
      throw FormatException('Missing "target_number" for Puzzle.');
    }
    if (json['initial_numbers'] == null || json['initial_numbers'] is! List) {
      throw FormatException('Missing or invalid "initial_numbers" for Puzzle.');
    }
    if (json['difficulty'] == null) {
      throw FormatException('Missing "difficulty" for Puzzle.');
    }

    List<int> initialNumbers = List<int>.from(json['initial_numbers']);
    return Puzzle(
      id: json['id'],
      targetNumber: json['target_number'],
      initialNumbers: initialNumbers,
      difficulty: json['difficulty'],
    );
  }

  toOptions() {
    List<NumberOption> options = initialNumbers
        .map((number) => NumberOption(
              id: number.toString(),
              value: number,
            ))
        .toList();

    return options;
  }
}
