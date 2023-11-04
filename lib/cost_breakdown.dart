import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wall_et_al/expense_pie_chart.dart';
import 'package:wall_et_al/routes.dart';

import 'add_expense.dart';
import 'database.dart';
import 'notifiers.dart';

class CostBreakdown extends StatefulWidget {
  const CostBreakdown({super.key});

  @override
  State<CostBreakdown> createState() => _CostBreakdownState();
}

class _CostBreakdownState extends State<CostBreakdown> {
  Future<List<ExpenseEntry>>? _expenses;
  late List<CategoryEntry> _categories;

  Widget _createExpenseView(BuildContext context, ExpenseEntry e) {
    final DateTime expenseTime =
        DateTime.fromMillisecondsSinceEpoch(e.msSinceEpoch);
    CategoryEntry category = _categories.firstWhere(
      (CategoryEntry cat) => cat.id == e.categoryId,
      orElse: () => ExpenseDatabase.nullCategory,
    );
    return Dismissible(
      key: Key(e.id.toString()), // UNIQUE KEY IS REQUIRED
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
      },
      confirmDismiss: (direction) async {
        var res = await ExpenseDatabase.instance.removeExpense(e);
        return res != 0;
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.color,
          child: Icon(category.icon,
              color: Theme.of(context).colorScheme.onBackground),
        ),
        title: Text(category.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(e.description),
        onTap: () => pushWithSlideUp(context, AddExpenseRoute(entry: e)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(e.amount.toStringAsFixed(2),
                style: const TextStyle(color: Colors.redAccent, fontSize: 18)),
            Text(
                "${expenseTime.day.toString().padLeft(2, '0')}-${expenseTime.month.toString().padLeft(2, '0')}-${expenseTime.year}",
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Future<List<ExpenseEntry>> _getExpenses(
      {String? timeFilter, Set<int>? includeCategories, Set<int>? includeTags}) {
    _expenses = ExpenseDatabase.instance.getExpenses(
        timeFilter: timeFilter, includeCategories: includeCategories, includeTags: includeTags);
    _getTotalExpense(_expenses!);
    return _expenses!;
  }

  Future<void> _getTotalExpense(Future<List<ExpenseEntry>> entries) async {
    double amount = 0;
    for (ExpenseEntry e in await entries) {
      amount += e.amount;
    }

    var expenseTotal = Provider.of<ExpenseTotal>(context, listen: false);
    expenseTotal.expenseTotal = amount;
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
    var excludeCategories = Provider.of<IncludeCategories>(context);
    var timeFilter = Provider.of<TimeFilter>(context);
    var includeTags = Provider.of<IncludeTags>(context);
    Provider.of<ExpenseDatabase>(context);

    return FutureBuilder(
        future: Future.wait([
          _getExpenses(
              timeFilter: timeFilter.timeFilter,
              includeCategories: excludeCategories.includeCategories,
              includeTags: includeTags.includeTags
          ),
          ExpenseDatabase.instance.getCategories()
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<ExpenseEntry> entries =
                snapshot.data![0] as List<ExpenseEntry>;
            _categories = snapshot.data![1] as List<CategoryEntry>;
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 150.0),
              itemCount: entries.length + 1,
              itemBuilder: (context, idx) {
                if (idx == 0) {
                  return Card(
                    margin: EdgeInsets.all(15),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Container(height: 450, child: ExpensePieChart(expenses: entries, categories: _categories)),
                  );
                } else {
                  return _createExpenseView(context, entries[idx - 1]);
                }

              }
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
