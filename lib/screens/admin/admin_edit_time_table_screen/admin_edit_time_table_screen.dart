import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/auth_provider.dart';
import 'package:potential_plus/screens/admin/admin_edit_time_table_screen/select_class_dropdown.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/utils.dart';

class AdminEditTimeTableScreen extends ConsumerStatefulWidget {
	const AdminEditTimeTableScreen({super.key});

	@override
  ConsumerState<AdminEditTimeTableScreen> createState() => _AdminEditTimeTableScreenState();
}

class _AdminEditTimeTableScreenState extends ConsumerState<AdminEditTimeTableScreen> {
  InstitutionClass? selectedClass;

  @override
	Widget build(BuildContext context) {

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

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SelectClassDropdown(onValueChanged: (value)  {
                    setState(() { selectedClass = value; });
                  }),
                  Text(selectedClass?.timeTable.toString() ?? 'Class not selected'),
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