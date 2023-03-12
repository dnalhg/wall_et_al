import 'package:flutter/material.dart';
import 'package:wall_et_al/constants.dart';

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
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              padding: Constants.DEFAULT_EDGE_INSETS,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text(
                    Constants.APP_NAME,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Constants.LARGE_TEXT_FONT_SIZE,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, "/");
          },
        ),
        ListTile(
          leading: const Icon(Icons.category),
          title: const Text('Categories'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, Constants.CATEGORIES_PAGE_ROUTE);

            },
        ),
      ],
    ));
  }
}
