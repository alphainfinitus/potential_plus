import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/router/route_names.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/screens/auth/login_screen/login_form.dart';
import 'package:potential_plus/shared/app_bar_title.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(
          title: "",
        ),
      ),
      body: user.when(
          data: (appUser) {
            // Already logged in, redirect to home screen
            if (appUser != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(RouteNames.home);
              });
              return null;
            }

            return const Padding(
              padding: EdgeInsets.fromLTRB(32, 0, 32, 0),
              child: LoginForm(),
            );
          },
          error: (error, _) =>
              const Center(child: Text(TextLiterals.authStatusUnkown)),
          loading: () => const Center(child: CircularProgressIndicator())),
    );
  }
}
