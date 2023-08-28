import 'package:digitos/operations.dart';
import 'package:digitos/widgets/SuccessModal.dart';
import 'package:flutter/material.dart';

// TODO replace with remote data
int targetNumber = 10;

class NumberOption {
  const NumberOption({
    required this.id,
    required this.value,
    required this.selected, // TODO i think this selected prop is obsolete now
  });

  final String id;
  final int value;
  final bool selected;
}

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  List<NumberOption> options = [
    const NumberOption(id: '1', value: 1, selected: false),
    const NumberOption(id: '2', value: 2, selected: false),
    const NumberOption(id: '3', value: 3, selected: false),
    const NumberOption(id: '4', value: 4, selected: false),
    const NumberOption(id: '5', value: 5, selected: false),
    const NumberOption(id: '6', value: 6, selected: false)
  ];

  NumberOption? firstNumber;
  OperationEnums? selectedOperation;

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

    bool isInt = result is int;

    if (!isInt) {
      // TODO handle error - result is not an int
      return null;
    } else {
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
            selected: option.selected,
          ));
          idIncrementer++;
        }

        newOptions.insert(
          0,
          NumberOption(
            id: idIncrementer.toString(),
            value: result,
            selected: false,
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
            _resetGame();
            Navigator.of(context).pop();
          }),
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      options = [
        const NumberOption(id: '1', value: 1, selected: false),
        const NumberOption(id: '2', value: 2, selected: false),
        const NumberOption(id: '3', value: 3, selected: false),
        const NumberOption(id: '4', value: 4, selected: false),
        const NumberOption(id: '5', value: 5, selected: false),
        const NumberOption(id: '6', value: 6, selected: false)
      ];
      firstNumber = null;
      selectedOperation = null;
    });
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
          const Text(
            'Play the game...',
          ),
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
          Row(
            children: OperationEnums.values.map((operation) {
              return ElevatedButton(
                onPressed: firstNumber == null
                    ? null
                    : _selectOperation(operation: operation),
                child: Text(operation.name.toString()),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}