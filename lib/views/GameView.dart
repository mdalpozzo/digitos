import 'package:digitos/models/game_parameters.dart';
import 'package:digitos/operations.dart';
import 'package:digitos/services/game_service.dart';
import 'package:digitos/widgets/SuccessModal.dart';
import 'package:flutter/material.dart';

List<NumberOption> initialOptions = [
  const NumberOption(id: '1', value: 1),
  const NumberOption(id: '2', value: 2),
  const NumberOption(id: '3', value: 3),
  const NumberOption(id: '4', value: 4),
  const NumberOption(id: '5', value: 5),
  const NumberOption(id: '6', value: 6)
];

class NumberOption {
  const NumberOption({
    required this.id,
    required this.value,
  });

  final String id;
  final int value;
}

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  List<NumberOption> options = initialOptions;

  NumberOption? firstNumber;
  OperationEnums? selectedOperation;

  // TODO replace with remote data
  int targetNumber = 10;

  _selectNumber({required NumberOption numberOption}) {
    void innerSelect(bool? selected) {
      NumberOption? firstNumberRef = firstNumber;
      OperationEnums? selectedOperationRef = selectedOperation;

      if (firstNumberRef == null) {
        setState(() {
          firstNumber = numberOption;
        });
      } else if (firstNumberRef == numberOption) {
        setState(() {
          firstNumber = null;
        });
      } else if (selectedOperationRef == null) {
        // TODO handle error - operation not selected
        return;
      } else {
        // execute the operation
        _executeOperation(
          operation: selectedOperationRef,
          a: firstNumberRef,
          b: numberOption,
        );
      }
    }

    return innerSelect;
  }

  _selectOperation({required OperationEnums operation}) {
    void innerSelect() {
      setState(() {
        selectedOperation = operation == selectedOperation ? null : operation;
      });
    }

    return innerSelect;
  }

  _executeOperation(
      {required OperationEnums operation,
      required NumberOption a,
      required NumberOption b}) {
    num result = Operations.handleOperation(operation, a.value, b.value);

    if (result == targetNumber) {
      _showSuccessModal(context);
    }

    bool isInt = result is int || result.remainder(1.0) == 0.0;

    if (!isInt) {
      // TODO handle error - result is not an int
      return null;
    } else {
      int resultAsInt = result.toInt();

      setState(() {
        List<NumberOption> newOptions = [];

        int idIncrementer = 0;

        for (var option in options) {
          if (option.id == a.id || option.id == b.id) {
            continue;
          }

          newOptions.add(NumberOption(
            id: idIncrementer.toString(),
            value: option.value,
          ));
          idIncrementer++;
        }

        newOptions.insert(
          0,
          NumberOption(
            id: idIncrementer.toString(),
            value: resultAsInt,
          ),
        );

        options = newOptions;
        firstNumber = null;
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

  void _resetGame() {
    setState(() {
      options = [
        const NumberOption(id: '1', value: 1),
        const NumberOption(id: '2', value: 2),
        const NumberOption(id: '3', value: 3),
        const NumberOption(id: '4', value: 4),
        const NumberOption(id: '5', value: 5),
        const NumberOption(id: '6', value: 6)
      ];
      firstNumber = null;
      selectedOperation = null;
    });
  }

  void _startNewGame() async {
    // TODO get userid setup auth
    GameParameters? newGame =
        await GameService().getNewGame('isK5PU14l793GZlSxM16');
    if (newGame == null) {
      // handle error
    } else {
      setState(() {
        options = newGame.initialNumbers
            .map((number) => NumberOption(
                  id: number.toString(),
                  value: number,
                ))
            .toList();
        targetNumber = newGame.targetNumber;
        firstNumber = null;
        selectedOperation = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Column(
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        //
        // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
        // action in the IDE, or press "p" in the console), to see the
        // wireframe for each widget.
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Select a number.'),
              Text('2. Select an operation.'),
              Text('3. Select another number.'),
              Text('4. Repeat until you reach the target number.'),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Target number: $targetNumber',
            style: Theme.of(context).textTheme.headline4,
          ),
          const SizedBox(
            height: 20,
          ),
          Wrap(
            direction: Axis.vertical,
            children: [
              for (var numberOption in options)
                SizedBox(
                  width: 120,
                  child: CheckboxListTile(
                    title: Text(numberOption.value.toString()),
                    value: numberOption.id == firstNumber?.id,
                    onChanged: firstNumber != null &&
                            selectedOperation == null &&
                            numberOption.id != firstNumber?.id
                        ? null
                        : _selectNumber(numberOption: numberOption),
                    // controlAffinity:
                    //     ListTileControlAffinity.leading, //  <-- leading Checkbox
                  ),
                ),
            ],
          ),
          Wrap(
            children: OperationEnums.values.expand((operation) {
              return [
                ElevatedButton(
                  onPressed: firstNumber == null
                      ? null
                      : _selectOperation(operation: operation),
                  child: Text(operation.name.toString()),
                ),
                const SizedBox(
                  width: 5,
                )
              ];
            }).toList(),
          ),
        ],
      ),
    );
  }
}
