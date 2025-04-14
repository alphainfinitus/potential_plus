import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/screens/teacher/teacher_mark_attendance/attendance_list_view.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/utils.dart';

class TeacherMarkAttendanceScreen extends ConsumerWidget {
  const TeacherMarkAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Institution? institution = ref.watch(institutionProvider).value;
    final AsyncValue<Map<String, InstitutionClass>?> classes =
        ref.watch(classesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: "Mark Attendance"),
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

          return classes.when(
            data: (classList) {
              if (classList == null || classList.isEmpty) {
                return const Center(child: Text('No classes found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: classList.length,
                itemBuilder: (context, index) {
                  final institutionClass = classList.values.elementAt(index);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        institutionClass.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                      subtitle: Text(
                        'Class ID: ${institutionClass.id}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: Text(institutionClass.name),
                              ),
                              body: AttendanceListView(
                                  institutionClass: institutionClass),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            error: (error, _) => Center(child: Text('Error: $error')),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
        error: (error, _) =>
            const Center(child: Text(TextLiterals.authStatusUnkown)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
