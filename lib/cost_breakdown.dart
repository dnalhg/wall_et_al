import 'package:flutter/material.dart';

import 'database.dart';

class CostBreakdown extends StatefulWidget {
  final ExpenseDatabase db = const ExpenseDatabase();

  const CostBreakdown({super.key});

  @override
  State<CostBreakdown> createState() => _CostBreakdownState();
}

class _CostBreakdownState extends State<CostBreakdown>{

  ListTile _createExpenseView(ExpenseEntry e) {
    return ListTile(
      title: Text(e.description),
      subtitle: Text(e.amount.toStringAsFixed(2)),
    );
  }

  Future<List<ExpenseEntry>> _getExpenses() async {
    return await widget.db.getAllExpenses();
  }

  @override
  void initState() {
    super.initState();
    _getExpenses();
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
            itemBuilder: (context, idx) => _createExpenseView(entries[idx]),
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
