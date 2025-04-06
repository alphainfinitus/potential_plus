import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/providers/users_provider/users_provider.dart';
import 'package:potential_plus/screens/admin/admin_manage_students_screen/create_student_form.dart';
import 'package:potential_plus/screens/admin/admin_manage_students_screen/student_list_item.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/utils.dart';

class AdminManageStudentsScreen extends ConsumerWidget {
  const AdminManageStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Institution? institution = ref.watch(institutionProvider).value;
    final AsyncValue<Map<String, AppUser>> students =
        ref.watch(institutionStudentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: TextLiterals.manageStudents),
      ),
      body: user.when(
        data: (appUser) {
          // Not logged in, redirect to login screen
          if (appUser == null) {
            AppUtils.pushReplacementNamedAfterBuild(
                context, AppRoutes.login.path);
            return null;
          }

          if (institution == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Create student form
                CreateStudentForm(institutionId: institution.id),

                const SizedBox(height: 24),
                const Text(
                  TextLiterals.allStudents,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Students list
                Expanded(
                  child: students.when(
                    data: (studentsData) {
                      if (studentsData.isEmpty) {
                        return const Center(
                          child: Text(TextLiterals.noStudentsFound),
                        );
                      }

                      final studentsList = studentsData.values.toList();
                      return ListView.builder(
                        itemCount: studentsList.length,
                        itemBuilder: (context, index) {
                          return StudentListItem(
                            student: studentsList[index],
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child:
                          Text('${TextLiterals.errorLoadingStudentList}$error'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        error: (error, _) =>
            const Center(child: Text(TextLiterals.authStatusUnkown)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
