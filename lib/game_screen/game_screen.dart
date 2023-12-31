import 'package:digitos/models/number_option.dart';
import 'package:digitos/models/puzzle.dart';
import 'package:digitos/operations.dart';
import 'package:digitos/services/game_service.dart';
import 'package:digitos/elements/operationEnumToDisplayString.dart';
import 'package:digitos/widgets/SuccessModal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  Puzzle? puzzle;
  List<NumberOption> options = [];

  // TODO these should live in a GameScreenModel
  NumberOption? firstNumber;
  NumberOption? secondNumber;
  OperationEnums? selectedOperation;
  int numberOfOperations = 0;

  // TODO replace with remote data
  int targetNumber = 10;

  @override
  void initState() {
    super.initState();
    _fetchInitialOptions();
  }

  void _fetchInitialOptions() async {
    // Fetch initial options asynchronously
    // Replace the below line with your actual data fetching logic
    Puzzle? fetchedPuzzle = await GameService().getDailyPuzzle();

    if (fetchedPuzzle == null) {
      // TODO handle error
      setState(() {
        error = 'No puzzle found';
      });
      return null;
    }

    List<NumberOption> fetchedOptions = fetchedPuzzle.initialNumbers
        .map((number) => NumberOption(
              id: number.toString(),
              value: number,
            ))
        .toList();

    setState(() {
      puzzle = fetchedPuzzle;
      options = fetchedOptions;
      error = '';
    });
  }

  _selectNumber({required NumberOption numberOption}) {
    bool isFirstNumber = numberOption.id == firstNumber?.id;
    bool isSecondNumber = numberOption.id == secondNumber?.id;

    if (isFirstNumber) {
      // unselect
      setState(() {
        firstNumber = null;
      });
    } else if (isSecondNumber) {
      // unselect
      setState(() {
        secondNumber = null;
      });
    } else {
      // select
      if (firstNumber == null) {
        setState(() {
          firstNumber = numberOption;
        });
      } else {
        setState(() {
          secondNumber = numberOption;
        });
      }
    }
  }

  _selectOperation({required OperationEnums operation}) {
    setState(() {
      selectedOperation = operation == selectedOperation ? null : operation;
    });
  }

  void _showNotIntegerAlert(BuildContext context, num result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Non-Integer Result'),
          content:
              Text('The result of the division is not an integer: $result'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // TODO - submit button
  // execute the operation
  // _executeOperation(
  //   operation: selectedOperationRef,
  //   a: firstNumberRef,
  //   b: numberOption,
  // );
  _executeOperation({
    required OperationEnums operation,
    required NumberOption a,
    required NumberOption b,
  }) {
    num result = Operations.handleOperation(operation, a.value, b.value);

    if (result == targetNumber) {
      _showSuccessModal(context);
    }

    bool isInt = result is int || result.remainder(1.0) == 0.0;

    if (!isInt) {
      // TODO handle error - result is not an int
      _showNotIntegerAlert(context, result);
      return null;
    } else {
      int resultAsInt = result.toInt();

      setState(() {
        List<NumberOption> newOptions = [];

        int idIncrementer = 0;

        for (var option in options) {
          // skip the options that were used in the operation
          if (option.id == a.id || option.id == b.id) {
            continue;
          }

          // add leftover options and reset ids
          newOptions.add(NumberOption(
            id: idIncrementer.toString(),
            value: option.value,
          ));
          idIncrementer++;
        }

        // add the result of the operation to the beginning of the list
        newOptions.insert(
          0,
          NumberOption(
            id: idIncrementer.toString(),
            value: resultAsInt,
          ),
        );

        numberOfOperations++;
        options = newOptions;
        firstNumber = null;
        secondNumber = null;
        selectedOperation = null;
      });
    }
  }

  void _showSuccessModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SuccessModal(onConfirm: () {
            _startNewGame();
            Navigator.of(context).pop();
          }),
        );
      },
    );
  }

  void _clearSelection() {
    setState(() {
      firstNumber = null;
      selectedOperation = null;
      secondNumber = null;
    });
  }

  void _resetGame() {
    setState(() {
      options = puzzle?.toOptions();
      firstNumber = null;
      selectedOperation = null;
      secondNumber = null;
      numberOfOperations = 0;
    });
  }

  void _startNewGame() async {
    // TODO get userid, setup auth, some anonymous userid for those who don't set up accounts (deviceid?)
    Puzzle? newGame = await GameService().getNewGame(
      'userId',
      excludedPuzzleIds: [puzzle?.id ?? ''],
    );

    if (newGame == null) {
      // TODO handle error
    } else {
      setState(() {
        puzzle = newGame;
        options = newGame.toOptions();
        targetNumber = newGame.targetNumber;
        firstNumber = null;
        secondNumber = null;
        selectedOperation = null;
        numberOfOperations = 0;
      });
    }
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
    bool selectionsExist = firstNumber != null ||
        secondNumber != null ||
        selectedOperation != null;
    bool allSelectionsExist = firstNumber != null &&
        secondNumber != null &&
        selectedOperation != null;

    WidgetsBinding.instance.addPostFrameCallback((_) => _showErrorDialog());

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
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh),
                  color: Theme.of(context).colorScheme.surface,
                ),
                IconButton(
                  onPressed: _startNewGame,
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
                            SizedBox(
                              height: 80,
                              width: 80,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  targetNumber.toString(),
                                  // style: Theme.of(context)
                                  //     .textTheme
                                  //     .headlineLarge
                                  //     ?.copyWith(fontWeight: FontWeight.bold),
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
                            SizedBox(
                              height: 80,
                              width: 80,
                              child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Column(
                                    children: [
                                      const Row(
                                        children: [
                                          Text('Your Best: '),
                                          Text('4'),
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
                                _selectNumber(numberOption: numberOption);
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
                                    _selectOperation(operation: operation);
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
                                onPressed: _clearSelection,
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
                                  OperationEnums? selectedOperation =
                                      this.selectedOperation;
                                  NumberOption? firstNumber = this.firstNumber;
                                  NumberOption? secondNumber =
                                      this.secondNumber;

                                  if (selectedOperation == null ||
                                      firstNumber == null ||
                                      secondNumber == null) {
                                    // TODO handle error
                                  } else {
                                    _executeOperation(
                                      operation: selectedOperation,
                                      a: firstNumber,
                                      b: secondNumber,
                                    );
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
