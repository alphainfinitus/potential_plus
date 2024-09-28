import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/models/app_user/app_user.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/utils.dart';

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
            AppUtils.pushReplacementNamedAfterBuild(context, AppRoutes.login.path);
            return null;
          }

          // Logged in home-screens based on user role
          switch (appUser.role) {
            case UserRole.student:
              AppUtils.pushReplacementNamedAfterBuild(context, AppRoutes.studentHomeScreen.path);
              return null;
            case UserRole.teacher:
              AppUtils.pushReplacementNamedAfterBuild(context, AppRoutes.teacherHomeScreen.path);
              return null;
            case UserRole.admin:
              AppUtils.pushReplacementNamedAfterBuild(context, AppRoutes.adminHomeScreen.path);
              return null;
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