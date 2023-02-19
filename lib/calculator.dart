import 'package:flutter/material.dart';

import 'custom_icons.dart';

class Calculator extends StatelessWidget {
  static const String _defaultDisplayedAmount = '0';

  final Function onButtonPressed;
  final double minVal;

  double? computedAmount;
  String? _currentAction;
  String _displayedAmount = _defaultDisplayedAmount;

  Calculator({super.key, required this.onButtonPressed, this.minVal = double.negativeInfinity});

  void _modifyDisplayedValue(String value) {
    // Delete previous input, reset to default value if we delete everything
    if (value == 'del') {
      _displayedAmount = _displayedAmount.substring(0, _displayedAmount.length - 1);
      if (_displayedAmount.isEmpty) {
        _displayedAmount = _defaultDisplayedAmount;
      }
      return;
    }

    if (_displayedAmount == _defaultDisplayedAmount && value != '.') {
      _displayedAmount = value;
    } else {
      if (value != '.' || !_displayedAmount.contains('.')) {
        // Don't concatenate another . if one already exists
        _displayedAmount += value;
      }
    }
  }

  void _doEquals() {
    if (computedAmount )
  }

  void _registerButton(String value) {
    if (CalculatorButton.operations.contains(value)) {
      if (value == 'eq') {
        _doEquals();
      }
    } else {
      _modifyDisplayedValue(value);
    }

    onButtonPressed(_displayedAmount);
  }

  double getFinalAmount() {
    _registerButton('eq');
    return computedAmount == null ? double.nan : computedAmount!;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CalculatorButton(value: '7', onPressed: _registerButton),
              CalculatorButton(value: '4', onPressed: _registerButton),
              CalculatorButton(value: '1', onPressed: _registerButton),
              CalculatorButton(value: '.', onPressed: _registerButton),
            ],
          )
        ),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CalculatorButton(value: '8', onPressed: _registerButton),
              CalculatorButton(value: '5', onPressed: _registerButton),
              CalculatorButton(value: '2', onPressed: _registerButton),
              CalculatorButton(value: '0', onPressed: _registerButton),
            ],
          )
        ),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CalculatorButton(value: '9', onPressed: _registerButton),
              CalculatorButton(value: '6', onPressed: _registerButton),
              CalculatorButton(value: '3', onPressed: _registerButton),
              CalculatorButton(value: 'del', onPressed: _registerButton),
            ],
          )
        ),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CalculatorButton(value: 'div', onPressed: _registerButton),
              CalculatorButton(value: 'mul', onPressed: _registerButton),
              CalculatorButton(value: 'sub', onPressed: _registerButton),
              CalculatorButton(value: 'plus', onPressed: _registerButton),
              CalculatorButton(value: 'eq', onPressed: _registerButton),
            ],
          )
        ),
      ],
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String value;
  final Function onPressed;

  static final Map<String, Widget> _valueToIcon = ({for (int i in [for (int i = 0; i <= 9; i++) i]) i.toString() : Text(i.toString(), style: const TextStyle(fontSize: 30)) })
    ..addAll({
      '.' : const Text('.', style: TextStyle(fontSize: 30)),
      'del': const Icon(Icons.backspace, size: 18),
      'div': const Icon(CustomIcons.divide, size: 18),
      'mul': const Icon(Icons.close_sharp),
      'sub': const Icon(Icons.remove),
      'plus': const Icon(Icons.add),
      'eq': const Icon(CustomIcons.equals, size: 18),
    });

  static final Set<String> operations = {'div', 'mul', 'sub', 'plus', 'eq'};

  const CalculatorButton({super.key, required this.value, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          onPressed(value);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: operations.contains(value) ? Colors.grey : Colors.black12,
          shape: const BeveledRectangleBorder(side: BorderSide.none),
        ),
        child: _valueToIcon[value],
      ),
    );
  }
}