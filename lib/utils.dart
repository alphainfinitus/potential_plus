import 'package:flutter/widgets.dart';

class AppUtils {
  static void pushReplacementNamedAfterBuild(BuildContext context, String routeName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(routeName);
    });
  }

  static final List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
