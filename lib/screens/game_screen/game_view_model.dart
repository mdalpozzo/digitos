import 'package:flutter/material.dart';
import 'package:digitos/models/number_option.dart';
import 'package:digitos/models/puzzle.dart';
import 'package:digitos/services/operations.dart';
import 'package:digitos/services/game_service.dart';

class OperationResult {
  final bool success;
  final String message;

  OperationResult({
    required this.success,
    required this.message,
  });
}

class GameViewModel with ChangeNotifier {
  String error = '';
  Puzzle? puzzle;
  List<NumberOption> options = [];
  NumberOption? firstNumber;
  NumberOption? secondNumber;
  OperationEnums? selectedOperation;
  int numberOfOperations = 0;
  int targetNumber = 10;

  bool puzzleSolved = false;

  void initDailyPuzzle() async {
    Puzzle? fetchedPuzzle = await GameService().getDailyPuzzle();

    if (fetchedPuzzle == null) {
      // TODO handle error
      error = 'No puzzle found';
      notifyListeners();
      return;
    }

    options = fetchedPuzzle.toOptions();
    puzzle = fetchedPuzzle;
    error = '';
    notifyListeners();
  }

  void selectNumber(NumberOption numberOption) {
    bool isFirstNumber = numberOption.id == firstNumber?.id;
    bool isSecondNumber = numberOption.id == secondNumber?.id;

    if (isFirstNumber) {
      firstNumber = null;
    } else if (isSecondNumber) {
      secondNumber = null;
    } else {
      if (firstNumber == null) {
        firstNumber = numberOption;
      } else {
        secondNumber = numberOption;
      }
    }
    notifyListeners();
  }

  void selectOperation(OperationEnums operation) {
    selectedOperation = operation == selectedOperation ? null : operation;
    notifyListeners();
  }

  OperationResult executeOperation({
    required OperationEnums operation,
    required NumberOption a,
    required NumberOption b,
  }) {
    num result = Operations.handleOperation(operation, a.value, b.value);
    OperationResult operationResult =
        OperationResult(success: true, message: 'OK');

    if (result == targetNumber) {
      puzzleSolved = true;
    }

    bool isInt = result is int || result.remainder(1.0) == 0.0;
    if (!isInt) {
      operationResult = OperationResult(
        success: false,
        message: 'Result is not an integer',
      );
    } else {
      int resultAsInt = result.toInt();

      options = _updateOptionsWithResult(a, b, resultAsInt);
      numberOfOperations++;
      firstNumber = null;
      secondNumber = null;
      selectedOperation = null;
    }
    notifyListeners();

    return operationResult;
  }

  List<NumberOption> _updateOptionsWithResult(
      NumberOption a, NumberOption b, int result) {
    List<NumberOption> newOptions = [];
    int idIncrementer = 0;
    for (var option in options) {
      if (option.id == a.id || option.id == b.id) {
        continue;
      }
      newOptions
          .add(NumberOption(id: idIncrementer.toString(), value: option.value));
      idIncrementer++;
    }
    newOptions.insert(
        0, NumberOption(id: idIncrementer.toString(), value: result));
    return newOptions;
  }

  void clearSelection() {
    firstNumber = null;
    selectedOperation = null;
    secondNumber = null;
    notifyListeners();
  }

  void resetGame() {
    options = puzzle?.toOptions();
    firstNumber = null;
    secondNumber = null;
    selectedOperation = null;
    numberOfOperations = 0;
    puzzleSolved = false;
    notifyListeners();
  }

  void startNewGame() async {
    Puzzle? newGame = await GameService().getNewGame(
      'userId',
      excludedPuzzleIds: [puzzle?.id ?? ''],
    );

    if (newGame != null) {
      puzzle = newGame;
      options = newGame.toOptions();
      targetNumber = newGame.targetNumber;
      resetGame();
    } else {
      // todo
      // Handle error
    }
  }
}
