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
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:go_router/go_router.dart';

class TeacherMarkAttendanceScreen extends ConsumerStatefulWidget {
  const TeacherMarkAttendanceScreen({super.key});

  @override
  ConsumerState<TeacherMarkAttendanceScreen> createState() =>
      _TeacherMarkAttendanceScreenState();
}

class _TeacherMarkAttendanceScreenState
    extends ConsumerState<TeacherMarkAttendanceScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: "Mark Attendance"),
      ),
      body: _buildBody(context, ref),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Institution? institution = ref.watch(institutionProvider).value;
    final AsyncValue<Map<String, InstitutionClass>?> classes =
        ref.watch(classesProvider);

    return user.when(
      data: (appUser) {
        // Not logged in, redirect to login screen
        if (appUser == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.login.path);
          });
          return const SizedBox.shrink();
        }

        if (institution == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return classes.when(
          data: (classesMap) {
            if (classesMap == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final classes = classesMap.values.toList();

            if (classes.isEmpty) {
              return const Center(
                  child: Text('No classes found for this institution'));
            }

            return Expanded(
              child: ListView.builder(
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final institutionClass = classes[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(institutionClass.name),
                      subtitle: Text(
                          '${institutionClass.studentIds.length} students'),
                      onTap: () {
                        context.push(
                          '${AppRoutes.teacherMarkAttendance.path}/${institutionClass.id}',
                          extra: institutionClass,
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
          error: (error, _) => Center(child: Text('Error: $error')),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, _) =>
          const Center(child: Text(TextLiterals.authStatusUnkown)),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
