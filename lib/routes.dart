import 'package:flutter/cupertino.dart';

import 'add_categories.dart';
import 'constants.dart';
import 'main.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/': (_) => Main(),
  Constants.CATEGORIES_PAGE_ROUTE: (_) => AddCategoryPage()
};

void replaceWithNewPage(BuildContext context, String newRouteName) {
  if (!Navigator.canPop(context)) {
    String? currentRouteName = ModalRoute
        .of(context)
        ?.settings
        .name;
    if (currentRouteName != newRouteName) {
      // Slide transition
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 150),
          settings: RouteSettings(name: newRouteName),
          pageBuilder: (context, animation, secondaryAnimation) =>
              routes[newRouteName]!(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }
}

void pushWithSlideUp(BuildContext context, Widget widgetToPush) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          widgetToPush,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.easeInOutSine;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ),
  );
}


