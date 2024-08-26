import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/auth_provider.dart';
import 'package:potential_plus/screens/admin/admin_home_screen/admin_actions_section.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/shared/logout_button.dart';
import 'package:potential_plus/utils.dart';

class AdminHomeScreen extends ConsumerWidget {
	const AdminHomeScreen({super.key});

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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:[
                  Center(
                    child: Text(
                      'Welcome ${appUser.name.split(' ')[0]}, admin for the realm of ${appUser.institutionId}',
                      style: const TextStyle(fontSize: 20.0),
                    )
                  ),
                  const SizedBox(height: 32.0,),

                  AdminActionsSection(
                    title: 'Daily Actions :',
                    actions: {
                      'Edit Time Table': AppRoutes.adminEditTimeTable.path,
                    }
                  ),

                  const SizedBox(height: 32.0,),
                  const LogoutButton(),
                ]
              ),
            ),
          );
        },
        error: (error, _) => const Center(child: Text(TextLiterals.authStatusUnkown)),
        loading: () => const Center(child: CircularProgressIndicator())
      ),
		);
	}
}