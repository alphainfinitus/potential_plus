import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';

class AppUtils {

  static final List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static bool isUserAuthorized(ProviderContainer container,
      {required String requiredRole}) {
    final user = container.read(authProvider).value;
    return user != null && user.role.name == requiredRole;
  }

  static bool isUserAuthenticated(ProviderContainer container) {
    final user = container.read(authProvider).value;
    return user != null;
  }

}
