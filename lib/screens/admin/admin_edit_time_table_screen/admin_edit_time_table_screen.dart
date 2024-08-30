import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/auth_provider.dart';
import 'package:potential_plus/screens/admin/admin_edit_time_table_screen/select_class_dropdown.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/utils.dart';

class AdminEditTimeTableScreen extends ConsumerWidget {
	const AdminEditTimeTableScreen({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {

    final AsyncValue<AppUser?> user = ref.watch(authProvider);

		return Scaffold(
			appBar: AppBar(
				title: const AppBarTitle(title: "Edit Time Table",),
			),
			body: user.when(
        data: (appUser) {
          // Not logged in, redirect to login screen
          if (appUser == null) {
            AppUtils.pushReplacementNamedAfterBuild(context, AppRoutes.login.path);
            return null;
          }

          return const SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SelectClassDropdown()
                ],
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