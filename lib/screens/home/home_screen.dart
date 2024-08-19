import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/auth_provider.dart';
import 'package:potential_plus/screens/auth/login_screen.dart';
import 'package:potential_plus/screens/profile/profile_screen.dart';
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
        data: (value) {
          if (value == null) {
            return const Center(
              child: LoginScreen(),
            );
          }

          return const ProfileScreen();
        },
        error: (error, _) => const Text(TextLiterals.authStatusUnkown),
        loading: () => const CircularProgressIndicator()
      ),
		);
	}
}