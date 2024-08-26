import 'package:flutter/widgets.dart';

class AppUtils {
  static void pushReplacementNamedAfterBuild(BuildContext context, String routeName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(routeName);
    });
  }
}