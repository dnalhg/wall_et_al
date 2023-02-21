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
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late DateTime _displayedDate;
  late TimeOfDay _displayedTime;
  Function? _getFinalAmount;
  String _displayedAmount = "0";


  @override
  void initState() {
    super.initState();
    _calculator = Calculator(
      onButtonPressed: _setDisplayedAmount,
      getFinalAmountCallback: (Function callback) => _getFinalAmount = callback,
      entry: widget.entry,
    );
    _categoryController = TextEditingController(text: widget.entry?.category ?? 'None');
    _descriptionController = TextEditingController(text: widget.entry?.description);
    _displayedDate = DateTime.fromMillisecondsSinceEpoch(widget.entry?.msSinceEpoch ?? DateTime.now().millisecondsSinceEpoch);
    _displayedTime = TimeOfDay.fromDateTime(_displayedDate);
  }

  void _setDisplayedAmount(String amount) {
    setState(() {
      _displayedAmount = amount;
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

  String _getDescription() {
    return _descriptionController.value.text;
  }

  String _getCategory() {
    return _categoryController.value.text;
  }

  int _getDisplayedDateTimeInMs() {
    return DateTime(_displayedDate.year, _displayedDate.month, _displayedDate.day, _displayedTime.hour, _displayedTime.minute).millisecondsSinceEpoch;
  }

  ExpenseEntry _createExpense(String id, double finalAmount) {
    return ExpenseEntry(
      id: id,
      amount: finalAmount,
      msSinceEpoch: _getDisplayedDateTimeInMs(),
      description: _getDescription(),
      category: _getCategory(),
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
          ExpenseEntry e = _createExpense(dbId, finalAmount);
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
      ExpenseEntry newEntry = _createExpense(oldEntry.id, finalAmount);
      if (oldEntry != newEntry) {
        ExpenseDatabase.instance.updateExpense(newEntry);
      }

      return true;
    }
  }

  Future<void> _handleDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _displayedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _displayedDate) {
      setState(() {
        _displayedDate = picked;
      });
    }
  }

  Future<void> _handleTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _displayedTime,
    );
    if (picked != null && picked != _displayedTime) {
      setState(() {
        _displayedTime = picked;
      });
    }
  }

  Widget _currentAmountDisplay() {
    return Container(
      decoration: const BoxDecoration(color: Colors.lightBlue),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Positioned(
            top: 50,
            right: 20,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(_displayedAmount, style: const TextStyle(fontSize: 58, fontWeight: FontWeight.bold)),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 80,
            child: SizedBox(
              width: 150,
              child: TextFormField(
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  floatingLabelStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))
                ),
                controller: _categoryController,
              ),
            ),
          ),
          Positioned(
            right: 90,
            bottom: 80,
            child: InkWell(
              onTap: _handleDatePicker,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text('${_displayedDate.day.toString().padLeft(2, '0')}-${_displayedDate.month.toString().padLeft(2, '0')}-${_displayedDate.year}'),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 80,
            child: InkWell(
              onTap: _handleTimePicker,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timelapse),
                  const SizedBox(width: 8),
                  Text('${_displayedTime.hour}:${_displayedTime.minute}'),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: TextFormField(
              maxLines: 1,
              decoration: const InputDecoration(
                labelText: 'Description',
                floatingLabelStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))
              ),
              controller: _descriptionController,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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