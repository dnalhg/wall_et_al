import 'package:flutter/material.dart';

import 'add_expense.dart';
import 'database.dart';

class CostBreakdown extends StatefulWidget {
  final String filter;

  const CostBreakdown({super.key, required this.filter});

  @override
  State<CostBreakdown> createState() => _CostBreakdownState();
}

class _CostBreakdownState extends State<CostBreakdown>{

  void _expandExpense(BuildContext context, ExpenseEntry e) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExpenseRoute(entry: e)),
    ).then((_) => setState(() {}));
  }

  ListTile _createExpenseView(BuildContext context, ExpenseEntry e) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.heart_broken),
      ),
      title: Text(e.category),
      subtitle: Text(e.description),
      trailing: Text(e.amount.toStringAsFixed(2)),
      onTap: () => _expandExpense(context, e),
    );
  }

  Future<List<ExpenseEntry>> _getExpenses() {
    return ExpenseDatabase.instance.getExpenses(widget.filter);
  }

  @override
  void initState() {
    super.initState();
    _getExpenses();
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
