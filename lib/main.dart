import 'package:flutter/material.dart';

import 'add_expense.dart';
import 'cost_breakdown.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wall Et Al',
      theme: ThemeData(brightness: Brightness.dark),
      home: const Main(),
    );
  }
}

class Main extends StatelessWidget {
  const Main ({super.key});

  void _navigateToAddExpenseRoute(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseRoute()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CostBreakdown(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddExpenseRoute(context),
        backgroundColor: Colors.lightBlue,
        tooltip: 'Add new expense',
        child: const Icon(Icons.add),
      ),
    );
  }
}