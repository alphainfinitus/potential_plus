import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/auth_provider.dart';
import 'package:potential_plus/screens/auth/login_screen/login_form.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/utils.dart';

class LoginScreen extends ConsumerWidget {
	const LoginScreen({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {

    final AsyncValue<AppUser?> user = ref.watch(authProvider);

		return Scaffold(
			appBar: AppBar(
				title: const AppBarTitle(title: "",),
			),
			body: user.when(
        data: (appUser) {
          // Already logged in, redirect to home screen
          if (appUser != null) {
            AppUtils.pushReplacementNamedAfterBuild(context, AppRoutes.home.path);
            return null;
          }

          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: LoginForm(),
          );
        },
        error: (error, _) => const Center(child: Text(TextLiterals.authStatusUnkown)),
        loading: () => const Center(child: CircularProgressIndicator())
      ),
		);
	}
}