import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/firebase_options.dart';
import 'package:potential_plus/providers/current_theme_provider/current_theme_provider.dart';
import 'package:potential_plus/router/app_router.dart';
import 'package:potential_plus/services/fcm_service.dart';
import 'package:potential_plus/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize FCM service
  await FCMService.initialize();

  // Initialize the notification service
  await NotificationService().initialize();

  runApp(const ProviderScope(child: AppRootWidget()));
}

class AppRootWidget extends ConsumerWidget {
  const AppRootWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(currentThemeNotifierProvider);

    return MaterialApp.router(
      title: TextLiterals.appTitle,
      theme: currentTheme,
      routerConfig: router,
    );
  }
}
