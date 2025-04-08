import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/providers/users_provider/users_provider.dart';
import 'package:potential_plus/screens/admin/admin_manage_teachers_screen/create_teacher_form.dart';
import 'package:potential_plus/screens/admin/admin_manage_teachers_screen/teacher_list_item.dart';
import 'package:potential_plus/shared/app_bar_title.dart';

class AdminManageTeachersScreen extends ConsumerWidget {
  const AdminManageTeachersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Institution? institution = ref.watch(institutionProvider).value;
    final AsyncValue<Map<String, AppUser>> teachers =
        ref.watch(institutionTeachersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: TextLiterals.manageTeachers),
      ),
      body: user.when(
        data: (appUser) {
          // Not logged in, redirect to login screen
          if (appUser == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(AppRoutes.login.path);
            });
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
                // Create teacher form
                CreateTeacherForm(institutionId: institution.id),

                const SizedBox(height: 24),
                const Text(
                  TextLiterals.allTeachers,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Teachers list
                Expanded(
                  child: teachers.when(
                    data: (teachersData) {
                      if (teachersData.isEmpty) {
                        return const Center(
                          child: Text(TextLiterals.noTeachersFound),
                        );
                      }

                      final teachersList = teachersData.values.toList();
                      return ListView.builder(
                        itemCount: teachersList.length,
                        itemBuilder: (context, index) {
                          return TeacherListItem(
                            teacher: teachersList[index],
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('${TextLiterals.errorLoadingTeachers}$error'),
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
