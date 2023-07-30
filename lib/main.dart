import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wall_et_al/constants.dart';
import 'package:wall_et_al/notifiers.dart';
import 'package:wall_et_al/routes.dart';
import 'package:wall_et_al/side_bar.dart';
import 'package:wall_et_al/wallet_app_bar.dart';

import 'add_expense.dart';
import 'cost_breakdown.dart';
import 'database.dart';
import 'filter_bar.dart';

// TODO's
// Fix this god forsaken filter bar thing
// ANIIMATIONS BETWEEN PAGES
// Convert cost breakdown into stateless OR use providers instead

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => TimeFilter()),
    ChangeNotifierProvider(create: (_) => ExcludeCategories()),
    ChangeNotifierProvider(create: (_) => ExpenseTotal()),
    ChangeNotifierProvider(create: (_) => ExpenseDatabase.instance)
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var mainColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff477388),
      brightness: Brightness.dark,
      primary: const Color(0xff477388),
    );
    return MaterialApp(
      title: Constants.APP_NAME,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        appBarTheme: AppBarTheme(color: mainColorScheme.primary),
        colorScheme: mainColorScheme,
        iconTheme: const IconThemeData(color: Colors.white),
        scaffoldBackgroundColor: const Color(0xff1e2529),
        shadowColor: Colors.white
      ),
      routes: routes,
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<StatefulWidget> createState() => _MainState();
}

class _MainState extends State<Main> {
  bool _expandedBottomBar = false;

  void _toggleExpansion() {
    setState(() {
      _expandedBottomBar = !_expandedBottomBar;
    });
  }

  bool _getExpansionState() => _expandedBottomBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WalletAppBar(title: Constants.APP_NAME),
      // create a side menu using Drawer widget
      drawer: const SideBar(),
      body: Stack(children: [
        GestureDetector(
          onPanDown: (_) {
            if (_expandedBottomBar) {
              _toggleExpansion();
            }
          },
          child: const CostBreakdown(),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: FilterBar(
              onExpand: _toggleExpansion,
              getExpansionState: _getExpansionState,
            )),
      ]),
      floatingActionButton: _expandedBottomBar
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 75),
              child: FloatingActionButton(
                elevation: 5,
                onPressed: () =>
                    pushWithSlideUp(context, const AddExpenseRoute()),
                backgroundColor: Theme.of(context).colorScheme.primary,
                tooltip: 'Add new expense',
                child: Icon(Icons.add,
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ),
    );
  }
}
