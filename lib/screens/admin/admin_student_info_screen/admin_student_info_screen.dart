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
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/shared/institution/select_class_dropdown.dart';

class AdminStudentInfoScreen extends ConsumerWidget {
  const AdminStudentInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Institution? institution = ref.watch(institutionProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: "Student Info"),
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

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SelectClassDropdown(onValueChanged: (value)  {
                    ref.read(selectedClassProvider.notifier).state = value;
                  }),

                  const SizedBox(height: 32.0),

                  if(ref.watch(selectedClassProvider) == null) const Text("Please select a class to view students"),

                  if(ref.watch(selectedClassProvider) != null) _buildStudentListView(context, ref, institution, ref.watch(selectedClassProvider)!),
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

  Widget _buildStudentListView(BuildContext context, WidgetRef ref, Institution institution, InstitutionClass selectedClass) {
    final AsyncValue<Map<String, AppUser>> studentsAsync = ref.watch(classStudentsProvider(selectedClass.id));

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return const Center(child: Text('No students found in this class'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students.values.elementAt(index);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(student.name),
                subtitle: Text(student.email),
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error loading students: $error')),
    );
  }
}