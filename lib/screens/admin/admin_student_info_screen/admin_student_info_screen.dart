import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/shared/institution/select_class_dropdown.dart';
import 'package:potential_plus/utils.dart';

class AdminStudentInfoScreen extends ConsumerStatefulWidget {
  const AdminStudentInfoScreen({super.key});

  @override
  ConsumerState<AdminStudentInfoScreen> createState() => _AdminStudentInfoScreenState();
}

class _AdminStudentInfoScreenState extends ConsumerState<AdminStudentInfoScreen> {
  InstitutionClass? selectedClass;

  @override
  Widget build(BuildContext context) {

    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Institution? institution = ref.watch(institutionProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: "Student Info",),
      ),
      body: user.when(
        data: (appUser) {
          // Not logged in, redirect to login screen
          if (appUser == null) {
            AppUtils.pushReplacementNamedAfterBuild(context, AppRoutes.login.path);
            return null;
          }

          if (institution == null) {
            return const Center(child: CircularProgressIndicator());
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

                  const SizedBox(height: 32.0),

                  if(selectedClass != null) _buildStudentListView(institution, selectedClass!),
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

  Widget _buildStudentListView(Institution institution, InstitutionClass selectedClass) {
    return const Placeholder();
  }
}