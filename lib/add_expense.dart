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
  String displayedAmount = "0";
  String _selectedCategory = 'None';

  _AddExpenseState() {
    _calculator = Calculator(onButtonPressed: _setDisplayedAmount, minVal: 0.0);
  }

  void _setDisplayedAmount(String amount) {
    setState(() {
      displayedAmount = amount;
    });
  }

  void _saveExpense() {
    // Do database saving
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