import 'package:flutter/material.dart';

import 'add_expense.dart';
import 'database.dart';

class CostBreakdown extends StatefulWidget {
  final String filter;
  final Function updateAppBar;

  const CostBreakdown({super.key, required this.filter, required this.updateAppBar});

  @override
  State<CostBreakdown> createState() => _CostBreakdownState();
}

class _CostBreakdownState extends State<CostBreakdown>{
  String? _filter;
  Future<List<ExpenseEntry>>? _expenses;

  void _expandExpense(BuildContext context, ExpenseEntry e) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExpenseRoute(entry: e)),
    ).then((_) => setState(() {}));
  }

  ListTile _createExpenseView(BuildContext context, ExpenseEntry e) {
    final DateTime expenseTime = DateTime.fromMillisecondsSinceEpoch(e.msSinceEpoch);
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.heart_broken),
      ),
      title: Text(e.category),
      subtitle: Text(e.description),
      onTap: () => _expandExpense(context, e),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(e.amount.toStringAsFixed(2), style: const TextStyle(color: Colors.redAccent, fontSize: 20)),
          Text("${expenseTime.day.toString().padLeft(2, '0')}-${expenseTime.month.toString().padLeft(2, '0')}-${expenseTime.year}", style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Future<List<ExpenseEntry>> _getExpenses() {
    if (widget.filter == _filter && _expenses != null) {
      return _expenses!;
    }
    _filter = widget.filter;
    _expenses = ExpenseDatabase.instance.getExpenses(widget.filter);
    return _expenses!;
  }

  Future<double> _getTotalExpense() async {
    final List<ExpenseEntry> entries = await _getExpenses();
    double amount = 0;
    for (ExpenseEntry e in entries) {
      amount += e.amount;
    }
    return amount;
  }

  @override
  void initState() {
    super.initState();
    _getExpenses();
    _getTotalExpense().then((totalAmount) => widget.updateAppBar([
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              padding: const EdgeInsets.only(right: 15.0, bottom: 5.0),
              child: Text(totalAmount.toStringAsFixed(2), style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    ]));
  }

  @override
  void didUpdateWidget(CostBreakdown oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExpenseEntry>>(
      future: _getExpenses(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<ExpenseEntry> entries = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom:150.0),
            itemCount: entries.length,
            itemBuilder: (context, idx) => _createExpenseView(context, entries[idx]),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      }
    );
  }
}
