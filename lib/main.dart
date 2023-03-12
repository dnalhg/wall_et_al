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
        Constants.CATEGORIES_PAGE_ROUTE: (context) => const AddCategoryPage(isChoosing: false)
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
  String _timeFilter = FilterBar.getDefaultTimeFilterString();
  List<Widget>? _actions;

  void _updateAppBar(List<Widget> actions) {
    setState(() {
      _actions = actions;
    });
  }

  void _updateTimeFilter(String timeFilter) {
    setState(() {
      _timeFilter = timeFilter;
      _forceUpdate = true;
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
              timeFilter: _timeFilter,
              forceUpdate: _forceUpdate,
              onUpdate: () {
                _forceUpdate = false;
              },
              updateAppBar: _updateAppBar
          ),
        ),
        Align(alignment: Alignment.bottomCenter, child: FilterBar(onExpand: _toggleExpansion, getExpansionState: _getExpansionState, updateTimeFilter: _updateTimeFilter)),
      ]),
      floatingActionButton: _expandedBottomBar ? null : Padding(
        padding: const EdgeInsets.only(bottom: 75),
        child: FloatingActionButton(
            onPressed: () => _navigateToAddExpenseRoute(context),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            tooltip: 'Add new expense',
            child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
          ),
      ),
    );
  }
}