import 'package:flutter/material.dart';

import 'calculator.dart';
import 'database.dart';

class AddExpenseRoute extends StatefulWidget {
  final ExpenseDatabase db = const ExpenseDatabase();

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

  void _raiseError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool _saveExpense() {
    double finalAmount = _getFinalAmount == null ? 0.0 : _getFinalAmount!();
    if (finalAmount.isNaN) {
      _raiseError("Invalid amount entered");
      return false;
    }

    Future<void> tryAddEntry() async {
      // Try insert 5 times with retries
      for (int i=0; i < 5; i++) {
        String dbId = DatabaseUtils.createCryptoRandomString();
        ExpenseEntry e = ExpenseEntry(
          id: dbId,
          amount: finalAmount,
          msSinceEpoch: DateTime.now().millisecondsSinceEpoch, //TODO: Support inputted time
          description: 'TODO',
          category: _selectedCategory,
        );
        int status = await widget.db.insertExpense(e);
        if (status != 0) {
          return;
        }
      }
      // Failed to add so raise an error
      _raiseError("Could not add expense to database");
    }

    tryAddEntry();
    return true;
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
            onPressed: () async {
              if (_saveExpense()) {
                Navigator.of(context).pop();
              }
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