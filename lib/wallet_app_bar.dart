import 'package:flutter/material.dart';


class WalletAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  late final bool showMenuButton;
  WalletAppBar({super.key, required this.title, this.actions, bool? showMenuButton}) {
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
      leading: widget.showMenuButton ? IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ) : null,
      actions: widget.actions,
    );
  }
}