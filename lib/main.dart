import 'package:flutter/material.dart';
import 'package:wall_et_al/add_categories.dart';
import 'package:wall_et_al/constants.dart';
import 'package:wall_et_al/side_bar.dart';
import 'package:wall_et_al/wallet_app_bar.dart';

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
      title: Constants.APP_NAME,
      theme: ThemeData(brightness: Brightness.dark),
      home: const Main(),
      routes: {
        Constants.CATEGORIES_PAGE_ROUTE: (context) => AddCategoryPage()
      },
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<StatefulWidget> createState() => _MainState();
}
class _MainState extends State<Main>{

  String filter = '';

  void _navigateToAddExpenseRoute(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseRoute()),
    ).then((val) => setState(() {
        filter = filter;
      }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WalletAppBar(title: Constants.APP_NAME),
      // create a side menu using Drawer widget
      drawer: const SideBar(),
      body: CostBreakdown(filter: filter),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddExpenseRoute(context),
        backgroundColor: Colors.lightBlue,
        tooltip: 'Add new expense',
        child: const Icon(Icons.add),
      ),
    );
  }
}