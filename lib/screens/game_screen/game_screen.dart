import 'package:digitos/view_models/game_view_model.dart';
import 'package:digitos/models/number_option.dart';
import 'package:digitos/services/account_service.dart';
import 'package:digitos/services/operations.dart';
import 'package:digitos/widgets/operationEnumToDisplayString.dart';
import 'package:digitos/widgets/SuccessModal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
// action in the IDE, or press "p" in the console), to see the
// wireframe for each widget.

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String error = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameViewModel = Provider.of<GameViewModel>(context, listen: false);
      gameViewModel.initDailyPuzzle();
    });
  }

  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('Non-Integer Result'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessModal(BuildContext context) {
    final gameViewModel = Provider.of<GameViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SuccessModal(
            onConfirm: () {
              gameViewModel.startNewGame();
              Navigator.of(context).pop();
            },
            numberOfMoves: gameViewModel.numberOfOperations,
          ),
        );
      },
    );
  }

  void _exit(BuildContext context) async {
    context.go('/');
  }

  void _showErrorDialog() {
    if (error.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(error),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  _exit(context);

                  setState(() {
                    error = ''; // Reset the error message
                  });
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameViewModel = context.watch<GameViewModel>();

    List<NumberOption> options = gameViewModel.options;
    NumberOption? firstNumber = gameViewModel.firstNumber;
    NumberOption? secondNumber = gameViewModel.secondNumber;
    OperationEnums? selectedOperation = gameViewModel.selectedOperation;
    int numberOfOperations = gameViewModel.numberOfOperations;
    int targetNumber = gameViewModel.targetNumber;

    bool selectionsExist = firstNumber != null ||
        secondNumber != null ||
        selectedOperation != null;
    bool allSelectionsExist = firstNumber != null &&
        secondNumber != null &&
        selectedOperation != null;

    // why?
    // WidgetsBinding.instance.addPostFrameCallback((_) => _showErrorDialog());

    return options.isEmpty
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Digitos'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              titleTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 20,
              ),
              actions: [
                IconButton(
                  onPressed: gameViewModel.resetGame,
                  icon: const Icon(Icons.refresh),
                  color: Theme.of(context).colorScheme.surface,
                ),
                IconButton(
                  onPressed: gameViewModel.startNewGame,
                  icon: const Icon(Icons.fast_forward),
                  color: Theme.of(context).colorScheme.surface,
                ),
                IconButton(
                  onPressed: () {
                    _exit(context);
                  },
                  icon: const Icon(Icons.exit_to_app),
                  color: Theme.of(context).colorScheme.surface,
                )
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Target',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  targetNumber.toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Moves',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            Expanded(
                              child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Text('Your Best: '),
                                          Selector<GameViewModel, int?>(
                                            selector: (_, viewModel) =>
                                                viewModel.bestScore,
                                            builder:
                                                (context, bestScore, child) {
                                              return Text(
                                                bestScore == null
                                                    ? '-'
                                                    : bestScore.toString(),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      Text(numberOfOperations.toString(),
                                          style: const TextStyle(fontSize: 50)),
                                    ],
                                  )),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.primary,
                    height: 2,
                    thickness: 2,
                  ),
                  Container(
                    // decoration: BoxDecoration(
                    //   color: Colors.green[100],
                    // ),
                    height: 75,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                          '${firstNumber?.value != null ? firstNumber?.value.toString() : '_'} ${operationEnumToDisplayString(selectedOperation)} ${secondNumber?.value != null ? secondNumber?.value.toString() : '_'}'),
                    ),
                  ),
                  Container(
                    // decoration: BoxDecoration(
                    //   color: Colors.pink[100],
                    // ),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GridView.count(
                          crossAxisCount: 3, // 3 items per row
                          crossAxisSpacing:
                              5, // Horizontal spacing between items
                          mainAxisSpacing: 5, // Vertical spacing between items
                          shrinkWrap:
                              true, // Use this if GridView is inside a scrollable widget
                          physics:
                              NeverScrollableScrollPhysics(), // Disable scrolling inside GridView if it's nested in another scrollable
                          padding:
                              EdgeInsets.all(10), // Adjust padding as needed
                          children: options.map((numberOption) {
                            return OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                backgroundColor:
                                    numberOption.id == firstNumber?.id ||
                                            numberOption.id == secondNumber?.id
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                              ),
                              onPressed: () {
                                gameViewModel.selectNumber(numberOption);
                              },
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  int numberOfDigits =
                                      numberOption.value.toString().length;
                                  int textScaleFactor = numberOfDigits == 1
                                      ? 35
                                      : numberOfDigits == 2
                                          ? 50
                                          : 70;
                                  return Text(
                                    numberOption.value.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: numberOption.id ==
                                                      firstNumber?.id ||
                                                  numberOption.id ==
                                                      secondNumber?.id
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                        ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textScaler: TextScaler.linear(
                                        constraints.maxWidth / textScaleFactor),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: OperationEnums.values.expand((operation) {
                              return [
                                ElevatedButton(
                                  onPressed: () {
                                    gameViewModel.selectOperation(operation);
                                  },
                                  //       ElevatedButton.styleFrom(
                                  // shape: const CircleBorder(), // Makes the button circular
                                  // padding: EdgeInsets.zero, // Removes default padding
                                  // // Set a fixed size for the button (optional)
                                  // fixedSize: const Size(
                                  //   50,
                                  //   50,
                                  // )
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 20,
                                    ),
                                    backgroundColor: selectedOperation ==
                                            operation
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.surface,
                                  ),
                                  child: Text(
                                    operationEnumToDisplayString(operation),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                          color: selectedOperation == operation
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .inverseSurface,
                                        ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                )
                              ];
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center content vertically in the remaining space
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Visibility(
                              visible: selectionsExist,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: ElevatedButton(
                                onPressed: gameViewModel.clearSelection,
                                style: ElevatedButton.styleFrom(
                                  shape:
                                      const CircleBorder(), // Makes the button circular
                                  padding: EdgeInsets
                                      .zero, // Removes default padding
                                  fixedSize: const Size(
                                    50,
                                    50,
                                  ),
                                ),
                                child: const Icon(Icons.undo),
                              ),
                            ),
                            Visibility(
                              visible: allSelectionsExist,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (selectedOperation == null ||
                                      firstNumber == null ||
                                      secondNumber == null) {
                                    _showAlert(context,
                                        'Two numbers and an operation must be selected.');
                                  } else {
                                    OperationResult result =
                                        gameViewModel.executeOperation(
                                      operation: selectedOperation,
                                      a: firstNumber,
                                      b: secondNumber,
                                    );

                                    if (!result.success) {
                                      _showAlert(context, result.message);
                                    } else {
                                      // Success!
                                      if (gameViewModel.puzzleSolved) {
                                        _showSuccessModal(context);
                                      }
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape:
                                      const CircleBorder(), // Makes the button circular
                                  padding: EdgeInsets
                                      .zero, // Removes default padding
                                  // Set a fixed size for the button (optional)
                                  fixedSize: const Size(
                                    50,
                                    50,
                                  ), // You can adjust the size as needed
                                ),
                                child: const Icon(Icons.check),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
