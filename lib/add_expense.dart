import 'package:flutter/material.dart';

import 'calculator.dart';

class AddExpenseRoute extends StatefulWidget {
  const AddExpenseRoute({super.key});

  @override
  State<AddExpenseRoute> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpenseRoute> {

  // Effectively final
  late Calculator _calculator;
  Function? _getFinalAmount;
  String displayedAmount = "0";
  String _selectedCategory = 'None';

  _AddExpenseState() {
    _calculator = Calculator(
      onButtonPressed: _setDisplayedAmount,
      getFinalAmountCallback: (Function callback) => _getFinalAmount = callback,
    );
  }

  void _setDisplayedAmount(String amount) {
    setState(() {
      displayedAmount = amount;
    });
  }

  void _saveExpense() {
    double finalAmount = _getFinalAmount == null ? double.nan : _getFinalAmount!();
    // TODO Save in database
  }

  Widget _currentAmountDisplay() {
    return Container(
      decoration: const BoxDecoration(color: Colors.lightBlue),
      child: Center(
        child: Text(
          displayedAmount,
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _saveExpense();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _currentAmountDisplay()),
          Expanded(child: _calculator),
        ],
      ),
    );
  }
}