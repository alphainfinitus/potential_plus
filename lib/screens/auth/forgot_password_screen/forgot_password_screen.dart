import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user/app_user.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/utils.dart';

class ForgotPasswordScreen extends ConsumerWidget {
	const ForgotPasswordScreen({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {

    final AsyncValue<AppUser?> user = ref.watch(authProvider);

		return Scaffold(
			appBar: AppBar(
				title: const AppBarTitle(title: "Forgot Password ?",),
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
            child: Text('Forgot Password Screen here'),
          );
        },
        error: (error, _) => const Center(child: Text(TextLiterals.authStatusUnkown)),
        loading: () => const Center(child: CircularProgressIndicator())
      ),
		);
	}
}