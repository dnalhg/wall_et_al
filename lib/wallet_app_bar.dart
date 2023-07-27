import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wall_et_al/notifiers.dart';

class WalletAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  late final bool showMenuButton;
  List<Widget>? actions;

  WalletAppBar(
      {super.key, required this.title, this.actions, bool? showMenuButton}) {
    this.showMenuButton = showMenuButton ?? true;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<StatefulWidget> createState() => _WalletAppBarState();
}

class _WalletAppBarState extends State<WalletAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      // add a side menu button to the app bar
      automaticallyImplyLeading: false,
      leading: widget.showMenuButton
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            )
          : null,
      actions: widget.actions ??
          ([
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 15.0, bottom: 5.0),
                  child: () {
                    var total = Provider.of<ExpenseTotal>(context);
                    return Text(total.expenseTotal.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 20));
                  }(),
                ),
              ],
            ),
          ]),
    );
  }
}
