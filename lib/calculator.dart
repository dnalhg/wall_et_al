import 'package:flutter/material.dart';

import 'custom_icons.dart';
import 'database.dart';

class Calculator extends StatefulWidget {
  final Function onButtonPressed;
  final Function getFinalAmountCallback;
  final ExpenseEntry? entry;

  const Calculator(
      {super.key,
      required this.onButtonPressed,
      required this.getFinalAmountCallback,
      this.entry});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String? _prevInput;
  String? _currentAction;
  late String _currentInput;

  @override
  void initState() {
    super.initState();
    _resetState(entry: widget.entry);
    widget.getFinalAmountCallback(() => _getFinalAmount());
  }

  void _resetState({ExpenseEntry? entry}) {
    if (entry == null) {
      _currentInput = '';
    } else {
      _currentInput = _getComputedAmountAsString(entry.amount);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onButtonPressed(_currentInput));
    }
    _prevInput = null;
    _currentAction = null;
  }

  void _modifyCurrentInput(String value) {
    // Delete previous input, reset to default value if we delete everything
    if (value == _CalculatorOperations.delete.name) {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      if (_currentInput.isEmpty && _prevInput != null) {
        _currentInput = '0';
      }
      return;
    }

    if ((_currentInput.isEmpty || _currentInput == '0') && value != '.') {
      _currentInput = value;
      if (value == '-') {
        _currentInput += '0';
      }
    } else if (_currentInput == '-0' && value != '.') {
      _currentInput = '-$value';
    } else {
      if (_currentInput.isEmpty && value == '.') {
        // Concatenate a 0 if the first input is a .
        _currentInput = '0.';
      } else if (value != '.' || !_currentInput.contains('.')) {
        // Don't concatenate another . if one already exists
        _currentInput += value;
      }
    }
  }

  String _getComputedAmountAsString(double computedAmount) {
    if (computedAmount.isNaN || computedAmount.isInfinite) {
      return "ERR";
    }
    String trimmedAmount = computedAmount.toStringAsFixed(2);
    if (trimmedAmount.contains('.')) {
      while (trimmedAmount.endsWith('0')) {
        trimmedAmount = trimmedAmount.substring(0, trimmedAmount.length - 1);
      }
      if (trimmedAmount.endsWith('.')) {
        trimmedAmount = trimmedAmount.substring(0, trimmedAmount.length - 1);
      }
    }
    return trimmedAmount;
  }

  void _handleOperator(String value) {
    if (_currentInput.isEmpty) {
      if (value == _CalculatorOperations.subtract.name && _prevInput == null) {
        _modifyCurrentInput('-');
      }
      if (_prevInput != null) {
        _currentAction = value;
      }
    } else {
      if (_currentAction != null && _currentInput.isNotEmpty) {
        _doEquals();
      } else {
        _prevInput = _currentInput;
      }
      _currentAction = value;
      _currentInput = '';
    }
  }

  void _doEquals() {
    if (_currentInput.isEmpty) {
      _currentAction = null;
      return;
    }

    double computedAmount = double.nan;
    if (_currentAction != null) {
      // Do operation
      double prev = double.tryParse(_prevInput ?? '') ?? double.nan;
      double curr = double.tryParse(_currentInput) ?? double.nan;
      if (_currentAction == _CalculatorOperations.plus.name) {
        computedAmount = prev + curr;
      } else if (_currentAction == _CalculatorOperations.subtract.name) {
        computedAmount = prev - curr;
      } else if (_currentAction == _CalculatorOperations.multiply.name) {
        computedAmount = prev * curr;
      } else if (_currentAction == _CalculatorOperations.divide.name) {
        computedAmount = prev / curr;
      }
    } else {
      computedAmount = double.tryParse(_currentInput) ?? double.nan;
    }

    _prevInput = _getComputedAmountAsString(computedAmount);
    _currentAction = null;
    _currentInput = '';
  }

  String _getDisplayedAmount() {
    if (_currentInput.isNotEmpty) {
      return _currentInput;
    }
    if (_prevInput != null) {
      return _prevInput!;
    }
    return '0';
  }

  void _registerButton(String value) {
    if (_prevInput == "ERR" || _currentInput == "ERR") {
      _resetState();
    }
    if (_CalculatorOperationsExt.isArithmeticOperation(value)) {
      if (value == _CalculatorOperations.equals.name) {
        _doEquals();
        _currentInput = _prevInput!;
        _prevInput = null;
      } else {
        _handleOperator(value);
      }
    } else {
      _modifyCurrentInput(value);
    }

    widget.onButtonPressed(_getDisplayedAmount());
  }

  double _getFinalAmount() {
    _registerButton(_CalculatorOperations.equals.name);
    return double.tryParse(_currentInput) ?? double.nan;
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
            )),
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
            )),
        Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CalculatorButton(value: '9', onPressed: _registerButton),
                CalculatorButton(value: '6', onPressed: _registerButton),
                CalculatorButton(value: '3', onPressed: _registerButton),
                CalculatorButton(
                    value: _CalculatorOperations.delete.name,
                    onPressed: _registerButton),
              ],
            )),
        Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CalculatorButton(
                    value: _CalculatorOperations.divide.name,
                    onPressed: _registerButton),
                CalculatorButton(
                    value: _CalculatorOperations.multiply.name,
                    onPressed: _registerButton),
                CalculatorButton(
                    value: _CalculatorOperations.subtract.name,
                    onPressed: _registerButton),
                CalculatorButton(
                    value: _CalculatorOperations.plus.name,
                    onPressed: _registerButton),
                CalculatorButton(
                    value: _CalculatorOperations.equals.name,
                    onPressed: _registerButton),
              ],
            )),
      ],
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String value;
  final Function onPressed;

  static final Map<String, Widget> _valueToIcon = ({
    for (int i in [for (int i = 0; i <= 9; i++) i])
      i.toString(): Text(i.toString(),
          style: const TextStyle(fontSize: 30, color: Colors.white54))
  })
    ..addAll({
      '.': const Text('.',
          style: TextStyle(fontSize: 30, color: Colors.white54)),
      _CalculatorOperations.delete.name:
          const Icon(Icons.backspace, size: 18, color: Colors.white60),
      _CalculatorOperations.divide.name:
          const Icon(CustomIcons.divide, size: 18, color: Colors.white54),
      _CalculatorOperations.multiply.name:
          const Icon(Icons.close_sharp, color: Colors.white54),
      _CalculatorOperations.subtract.name:
          const Icon(Icons.remove, color: Colors.white54),
      _CalculatorOperations.plus.name:
          const Icon(Icons.add, color: Colors.white54),
      _CalculatorOperations.equals.name:
          const Icon(CustomIcons.equals, size: 18, color: Colors.white54),
    });

  const CalculatorButton(
      {super.key, required this.value, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          onPressed(value);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _CalculatorOperationsExt.isArithmeticOperation(value) &&
                      value != _CalculatorOperations.delete.name
                  ? Theme.of(context).colorScheme.background
                  : Colors.black12,
          shape: const BeveledRectangleBorder(side: BorderSide.none),
        ),
        child: _valueToIcon[value],
      ),
    );
  }
}

enum _CalculatorOperations { delete, divide, multiply, subtract, plus, equals }

extension _CalculatorOperationsExt on _CalculatorOperations {
  static final Set<String> _operationNames =
      _CalculatorOperations.values.map((o) => o.name).toSet();

  static bool isArithmeticOperation(String operationName) {
    return _operationNames.contains(operationName) &&
        operationName != _CalculatorOperations.delete.name;
  }
}
