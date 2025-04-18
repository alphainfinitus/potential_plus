import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';

class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Institution? institution = ref.watch(institutionProvider).value;

    return user.when(
        data: (appUser) {
          // Not logged in, redirect to login screen
          if (appUser == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(AppRoutes.login.path);
            });
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          if (institution == null) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          // Redirect to dashboard
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.teacherDashboard.path);
          });
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        },
        error: (error, _) => const Scaffold(
            body: Center(child: Text(TextLiterals.authStatusUnkown))),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())));
  }
}
