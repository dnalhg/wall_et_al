import 'package:flutter/material.dart';

import 'calculator.dart';
import 'database.dart';

class AddExpenseRoute extends StatefulWidget {
  final ExpenseEntry? entry;

  const AddExpenseRoute({super.key, this.entry});

  @override
  State<AddExpenseRoute> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpenseRoute> {

  late Calculator _calculator;
  late String _selectedCategory;
  int msSinceEpoch = DateTime.now().millisecondsSinceEpoch; // TODO
  String description = 'TODO'; // TODO
  Function? _getFinalAmount;
  String displayedAmount = "0";

  @override
  void initState() {
    super.initState();
    _calculator = Calculator(
      onButtonPressed: _setDisplayedAmount,
      getFinalAmountCallback: (Function callback) => _getFinalAmount = callback,
      entry: widget.entry,
    );
    _selectedCategory = widget.entry?.category ?? 'None';
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

    if (widget.entry == null) {
      Future<void> tryAddEntry() async {
        // Try insert 5 times with retries
        for (int i=0; i < 5; i++) {
          String dbId = DatabaseUtils.createCryptoRandomString();
          ExpenseEntry e = ExpenseEntry(
            id: dbId,
            amount: finalAmount,
            msSinceEpoch: msSinceEpoch,
            description: description,
            category: _selectedCategory,
          );
          int status = await ExpenseDatabase.instance.insertExpense(e);
          if (status != 0) {
            return;
          }
        }
        // Failed to add so raise an error
        _raiseError("Could not add expense to database");
      }

      tryAddEntry();
      return true;
    } else {
      ExpenseEntry oldEntry = widget.entry!;
      ExpenseEntry newEntry = ExpenseEntry(
        id: oldEntry.id,
        amount: finalAmount,
        msSinceEpoch: msSinceEpoch,
        description: description,
        category: _selectedCategory,
      );
      if (oldEntry == newEntry) {
        return true;
      }
      ExpenseDatabase.instance.updateExpense(newEntry);

      return true;
    }
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
          if (widget.entry != null)...[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              ExpenseDatabase.instance.removeExpense(widget.entry!);
              Navigator.of(context).pop();
            },
          )],
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