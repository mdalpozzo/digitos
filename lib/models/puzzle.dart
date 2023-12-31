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
