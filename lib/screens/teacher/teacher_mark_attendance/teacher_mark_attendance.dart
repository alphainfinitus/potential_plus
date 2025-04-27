import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/screens/teacher/teacher_mark_attendance/attendance_list_view.dart';
import 'package:potential_plus/shared/institution/select_class_dropdown.dart';
import 'package:potential_plus/shared/app_bar_title.dart';

class TeacherMarkAttendanceScreen extends ConsumerStatefulWidget {
  const TeacherMarkAttendanceScreen({super.key});

  @override
  ConsumerState<TeacherMarkAttendanceScreen> createState() =>
      _TeacherMarkAttendanceScreenState();
}

class _TeacherMarkAttendanceScreenState
    extends ConsumerState<TeacherMarkAttendanceScreen> {
  InstitutionClass? selectedClass;

  @override
  Widget build(BuildContext context) {
    // Replace the ref.listen with a safer watch
    final classesState = ref.watch(classesProvider);

    // Handle the AsyncValue state of classesProvider
    classesState.whenData((classes) {
      if (classes != null && selectedClass != null) {
        final updatedClass = classes.firstWhere(
          (element) => element.id == selectedClass?.id,
          orElse: () => selectedClass!,
        );
        if (updatedClass != selectedClass) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              selectedClass = updatedClass;
            });
          });
        }
      }
    });

    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Institution? institution = ref.watch(institutionProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: "Mark Attendance"),
      ),
      body: user.when(
          data: (appUser) {
            // Not logged in, redirect to login screen
            if (appUser == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/login');
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
                    SelectClassDropdown(onValueChanged: (value) {
                      setState(() {
                        selectedClass = value;
                      });
                    }),
                    const SizedBox(height: 32.0),
                    if (selectedClass != null)
                      AttendanceListView(institutionClass: selectedClass!),
                  ],
                ),
              ),
            );
          },
          error: (error, _) =>
              const Center(child: Text(TextLiterals.authStatusUnkown)),
          loading: () => const Center(child: CircularProgressIndicator())),
    );
  }
}
