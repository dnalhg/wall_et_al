import 'package:flutter/material.dart';
import 'package:wall_et_al/constants.dart';
import 'package:wall_et_al/routes.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        SizedBox(
            height: 150,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              padding: Constants.DEFAULT_EDGE_INSETS,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(Constants.APP_NAME,
                      style: Theme.of(context).primaryTextTheme.titleLarge),
                ],
              ),
            )),
        ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                replaceWithNewPage(context, "/");
              });
            }),
        ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            onTap: () {
              Navigator.pop(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                replaceWithNewPage(context, Constants.CATEGORIES_PAGE_ROUTE);
              });
            })
      ],
    ));
  }
}
