import 'package:flutter/material.dart';
import 'package:wall_et_al/add_categories.dart';
import 'package:wall_et_al/constants.dart';
import 'package:wall_et_al/side_bar.dart';
import 'package:wall_et_al/wallet_app_bar.dart';

import 'add_expense.dart';
import 'cost_breakdown.dart';
import 'filter_bar.dart';

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

  bool _expandedBottomBar = false;
  bool _forceUpdate = true;
  String filter = '';
  List<Widget>? _actions;

  void _updateAppBar(List<Widget> actions) {
    setState(() {
      _actions = actions;
    });
  }

  void _toggleExpansion() {
    setState(() {
      _expandedBottomBar = !_expandedBottomBar;
    });
  }

  bool _getExpansionState() => _expandedBottomBar;

  void _navigateToAddExpenseRoute(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseRoute()),
    ).then((val) => setState(() {
        _forceUpdate = true;
      }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WalletAppBar(title: Constants.APP_NAME, actions: _actions),
      // create a side menu using Drawer widget
      drawer: const SideBar(),
      body: Stack(children: [
        GestureDetector(
          onPanDown: (_) {
            if (_expandedBottomBar) {
              _toggleExpansion();
            }
          },
          child: CostBreakdown(
              forceUpdate: _forceUpdate,
              onUpdate: () {
                _forceUpdate = false;
              },
              updateAppBar: _updateAppBar
          ),
        ),
        Align(alignment: Alignment.bottomCenter, child: FilterBar(onExpand: _toggleExpansion, getExpansionState: _getExpansionState)),
      ]),
      floatingActionButton: _expandedBottomBar ? null : Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
            onPressed: () => _navigateToAddExpenseRoute(context),
            backgroundColor: Colors.lightBlue,
            tooltip: 'Add new expense',
            child: const Icon(Icons.add),
          ),
      ),
    );
  }
}