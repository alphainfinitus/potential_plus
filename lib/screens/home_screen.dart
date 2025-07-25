import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/router/route_names.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/shared/app_bar_title.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(),
      ),
      body: user.when(
          data: (appUser) {
            // Not logged in, redirect to login screen
            if (appUser == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(RouteNames.login);
              });
              return null;
            }

            // Logged in home-screens based on user role
            switch (appUser.role) {
              case UserRole.student:
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go(RouteNames.studentHome);
                });
                return null;
              case UserRole.teacher:
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go(RouteNames.teacherHome);
                });
                return null;
              case UserRole.admin:
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go(RouteNames.adminHome);
                });
                return null;
            }
          },
          error: (error, _) =>
              const Center(child: Text(TextLiterals.authStatusUnkown)),
          loading: () => const Center(child: CircularProgressIndicator())),
    );
  }
}
