import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/auth_provider.dart';
import 'package:potential_plus/screens/auth/login_screen.dart';
import 'package:potential_plus/screens/student/activity_feed/student_activity_feed.dart';
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
          if (appUser == null) {
            return const Center(
              child: LoginScreen(),
            );
          }

          switch (appUser.role) {
            case UserRole.student:
              return StudentActivityFeed(appUser: appUser);
            case UserRole.teacher:
              return const Center(
                child: Text('Teacher Home Screen'),
              );
            case UserRole.admin:
              return const Center(
                child: Text('Admin Home Screen'),
              );
            default:
              return const Center(
                child: Text('Error Code: 0x001 :( ${TextLiterals.genericError}'),
              );
          }
        },
        error: (error, _) => const Center(child: Text(TextLiterals.authStatusUnkown)),
        loading: () => const Center(child: CircularProgressIndicator())
      ),
		);
	}
}