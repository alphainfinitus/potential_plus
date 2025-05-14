import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart';

class StudentListWidget extends ConsumerStatefulWidget {
  const StudentListWidget({super.key});

  @override
  ConsumerState<StudentListWidget> createState() => _StudentListWidgetState();
}

class _StudentListWidgetState extends ConsumerState<StudentListWidget> {
  @override
  Widget build(BuildContext context) {
    final selectedClass = ref.watch(selectedClassProvider);
    final selectedLecture = ref.watch(selectedLectureProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (selectedClass == null || selectedLecture == null) {
      return const SizedBox.shrink();
    }

    final studentsAsync = ref.watch(classStudentsProvider(selectedClass.id));

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 48, color: colorScheme.outline),
                const SizedBox(height: 8),
                Text(
                  'No students found in this class',
                  style: TextStyle(
                    color: colorScheme.outline,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Students List Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Attendance',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Mark All Section
                  Consumer(
                    builder: (context, ref, child) {
                      final studentAttendance =
                          ref.watch(attendanceStateProvider);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Mark All Present
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: students.every(
                                    (student) =>
                                        studentAttendance[student.id] == true,
                                  ),
                                  onChanged: (value) {
                                    if (value == true) {
                                      final newAttendance =
                                          Map<String, bool>.fromEntries(
                                        students.map(
                                          (student) =>
                                              MapEntry(student.id, true),
                                        ),
                                      );
                                      ref
                                          .read(
                                              attendanceStateProvider.notifier)
                                          .state = newAttendance;
                                    }
                                  },
                                  activeColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Text(
                                  'Mark All Present',
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Mark All Absent
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: students.every(
                                    (student) =>
                                        studentAttendance[student.id] == false,
                                  ),
                                  onChanged: (value) {
                                    if (value == true) {
                                      final newAttendance =
                                          Map<String, bool>.fromEntries(
                                        students.map(
                                          (student) =>
                                              MapEntry(student.id, false),
                                        ),
                                      );
                                      ref
                                          .read(
                                              attendanceStateProvider.notifier)
                                          .state = newAttendance;
                                    }
                                  },
                                  activeColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Text(
                                  'Mark All Absent',
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Students List
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return Consumer(
                    builder: (context, ref, child) {
                      final studentAttendance =
                          ref.watch(attendanceStateProvider);
                      final isPresent = studentAttendance[student.id];

                      final cardColor = isPresent == null
                          ? colorScheme.surfaceContainerHighest.withOpacity(0.1)
                          : isPresent
                              ? colorScheme.tertiaryContainer.withOpacity(0.2)
                              : colorScheme.errorContainer.withOpacity(0.2);

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: isPresent == null
                                ? colorScheme.outline
                                : isPresent
                                    ? Colors.green
                                    : Colors.red,
                            child: Text(
                              student.name.isNotEmpty
                                  ? student.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            student.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Present Checkbox
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: isPresent == true,
                                    onChanged: (value) {
                                      if (value == true) {
                                        ref
                                            .read(attendanceStateProvider
                                                .notifier)
                                            .updateAttendance(student.id, true);
                                      }
                                    },
                                    activeColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Text(
                                    'Present',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              // Absent Checkbox
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: isPresent == false,
                                    onChanged: (value) {
                                      if (value == true) {
                                        ref
                                            .read(attendanceStateProvider
                                                .notifier)
                                            .updateAttendance(
                                                student.id, false);
                                      }
                                    },
                                    activeColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Text(
                                    'Absent',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 8),
            Text(
              'Error: $error',
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
