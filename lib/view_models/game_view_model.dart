import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/app_logger.dart';
import 'package:digitos/services/audio_service.dart';
import 'package:digitos/services/navigation_service.dart';
import 'package:digitos/view_models/base_view_model.dart';
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

class GameViewModel extends BaseViewModel {
  final AccountService accountService;
  final GameService gameService;
  final AudioService audioService;
  final NavigationService navigationService;
  static final _log = AppLogger('GameViewModel');

  GameViewModel({
    required this.accountService,
    required this.gameService,
    required this.audioService,
    required this.navigationService,
  }) {
    accountService.bestScore.listen((int? newBestScore) {
      bestScore = newBestScore;
      notifyListeners();
    });

    initDailyPuzzle();
  }

  String error = '';
  int? bestScore;
  Puzzle? puzzle;
  Puzzle? dailyPuzzle;
  List<NumberOption> options = [];
  NumberOption? firstNumber;
  NumberOption? secondNumber;
  OperationEnums? selectedOperation;
  int numberOfOperations = 0;
  int targetNumber = 10;

  bool puzzleSolved = false;

  void initDailyPuzzle() async {
    Puzzle? fetchedPuzzle = await gameService.getDailyPuzzle();

    if (fetchedPuzzle == null) {
      // TODO handle error
      error = 'No puzzle found';
      _log.severe('GameViewModel.initDailyPuzzle: No daily puzzle found');

      notifyListeners();
      return;
    }

    dailyPuzzle = fetchedPuzzle;

    notifyListeners();
  }

  void setPuzzleToDaily() {
    setupPuzzle(dailyPuzzle!);
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

      if (result == puzzle?.targetNumber) {
        puzzleSolved = true;
        _handlePuzzleSolved(puzzle!);
      }
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
    Puzzle? p = puzzle;
    if (p == null) {
      _log.severe('GameViewModel.resetGame: No puzzle to reset');
      return;
    }

    setupPuzzle(p);
    notifyListeners();
  }

  // TODO this logic may need to be duplicate in other places like the home_view... refactor this so it's not duplicated
  Future<void> startNewGame() async {
    // TODO loading state in view
    Puzzle? newGame = await gameService.getNewGame();

    if (newGame != null) {
      puzzle = newGame;
      resetGame();
    } else {
      // todo
      // Handle error
      _log.severe('GameViewModel.startNewGame: No new game found');
    }
  }

// todo think about this for performance... some kind of loading animation or something? when should it actually fetch the data, now or loading state on game screen?
  Future<void> onPressLevelButton({int? difficulty}) async {
    _log.info('onPressLevelButton: $difficulty');
    gameService.selectedDifficulty = difficulty;
    audioService.playButtonTap();
    // Navigate to loading screen first, without transitions
    navigationService.navigateTo('/loading');

    // Start fetching data and wait for at least 1 minute and 40 seconds before proceeding
    await Future.wait([
      startNewGame(),
      Future.delayed(
        Duration(
          seconds: 1,
          milliseconds: 650,
        ),
      ), // Ensure animation plays at least once
    ]);

    navigationService.navigateTo('/game');
  }

// todo think about this for performance... some kind of loading animation or something? when should it actually fetch the data, now or loading state on game screen?
  Future<void> onPressDailyButton({int? difficulty}) async {
    _log.info('onPressLevelButton: $difficulty');
    audioService.playButtonTap();

    // Navigate to loading screen first, without transitions
    navigationService.navigateTo('/loading');

    setPuzzleToDaily();

    // Start fetching data and wait for at least 1 minute and 40 seconds before proceeding
    await Future.wait([
      Future.delayed(
        Duration(
          seconds: 1,
          milliseconds: 650,
        ),
      ), // Ensure animation plays at least once
    ]);

    // Then navigate to the game screen without transitions
    navigationService.navigateTo('/game');
  }

  void setupPuzzle(Puzzle p) {
    puzzle = p;
    options = p.toOptions();
    targetNumber = p.targetNumber;
    firstNumber = null;
    secondNumber = null;
    selectedOperation = null;
    numberOfOperations = 0;
    puzzleSolved = false;
    error = '';
    notifyListeners();
  }

  void _handlePuzzleSolved(Puzzle puzzle) async {
    // TODO handle errors
    await accountService.addNewCompletedGame(puzzle.id, numberOfOperations);
  }
}
