import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/screens/admin/admin_manage_classes_screen/add_students_dialog.dart';
import 'package:potential_plus/screens/admin/admin_manage_classes_screen/class_list_item.dart';
import 'package:potential_plus/screens/admin/admin_manage_classes_screen/create_class_form.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/utils.dart';

class AdminManageClassesScreen extends ConsumerWidget {
  const AdminManageClassesScreen({super.key});

  void _showAddStudentsDialog(BuildContext context, WidgetRef ref, Institution institution,
      InstitutionClass selectedClass) {
    showDialog(
      context: context,
      builder: (context) => AddStudentsDialog(
        institution: institution,
        institutionClass: selectedClass,
      ),
    ).then((_) {
      // Refresh class students when the dialog is closed
      ref.invalidate(classStudentsProvider(selectedClass.id));
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Institution? institution = ref.watch(institutionProvider).value;
    final AsyncValue<Map<String, InstitutionClass>?> classes =
        ref.watch(classesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: TextLiterals.manageClasses),
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
                // Create class form
                CreateClassForm(institutionId: institution.id),

                const SizedBox(height: 24),
                const Text(
                  TextLiterals.allClasses,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Classes list
                Expanded(
                  child: classes.when(
                    data: (classesData) {
                      if (classesData == null || classesData.isEmpty) {
                        return const Center(
                          child: Text(TextLiterals.noClassesFound),
                        );
                      }

                      final classesList = classesData.values.toList();
                      return ListView.builder(
                        itemCount: classesList.length,
                        itemBuilder: (context, index) {
                          return ClassListItem(
                            classItem: classesList[index],
                            institution: institution,
                            onAddStudents: (classData) {
                              _showAddStudentsDialog(
                                  context, ref, institution, classData);
                            },
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('${TextLiterals.errorLoadingClasses}$error'),
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
