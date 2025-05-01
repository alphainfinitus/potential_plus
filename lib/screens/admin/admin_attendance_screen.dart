import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart'
    as attendance_provider;
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/widgets/custom_dropdown.dart';
import 'package:intl/intl.dart';

class AdminAttendanceScreen extends ConsumerWidget {
  const AdminAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClass = ref.watch(attendance_provider.selectedClassProvider);
    final selectedDate = ref.watch(attendance_provider.selectedDateProvider);
    final selectedLecture =
        ref.watch(attendance_provider.selectedLectureProvider);
    final studentAttendance =
        ref.watch(attendance_provider.studentAttendanceProvider);
    final classesAsync = ref.watch(classesProvider);
    final currentUser = ref.watch(authProvider).value;

    // Get color scheme for Material 3
    final colorScheme = Theme.of(context).colorScheme;

    // Watch for attendance params changes and update student attendance
    if (selectedClass != null && selectedLecture != null) {
      ref.listen(
        attendance_provider.lectureAttendanceProvider((
          classId: selectedClass.id,
          timeTableEntryId: selectedLecture.id,
          date: selectedDate,
        )),
        (previous, next) {
          next.whenData((attendanceMap) {
            if (attendanceMap.isNotEmpty) {
              ref
                  .read(attendance_provider.studentAttendanceProvider.notifier)
                  .state = attendanceMap;
            }
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        centerTitle: true,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selection Card
                Card(
                  elevation: 0,
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side:
                        BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Class Information',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),

                        // Class and Date Selection Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Class Selection
                            Expanded(
                              child: classesAsync.when(
                                data: (classes) =>
                                    CustomDropdown<InstitutionClass>(
                                  label: 'Class',
                                  value: selectedClass,
                                  items: classes!.map((cls) {
                                    return DropdownMenuItem(
                                      value: cls,
                                      child: Text(
                                        cls.name,
                                        style: TextStyle(
                                          color: colorScheme.onSurface,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    ref
                                        .read(attendance_provider
                                            .selectedClassProvider.notifier)
                                        .state = value;
                                    ref
                                        .read(attendance_provider
                                            .studentAttendanceProvider.notifier)
                                        .state = {};
                                    ref
                                        .read(attendance_provider
                                            .selectedLectureProvider.notifier)
                                        .state = null;
                                  },
                                  colorScheme: colorScheme,
                                ),
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (error, stack) => Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: colorScheme.error),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Error loading classes: $error',
                                          style: TextStyle(
                                              color: colorScheme.error),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Date Selection
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(DateTime.now().year),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    ref
                                        .read(attendance_provider
                                            .selectedDateProvider.notifier)
                                        .state = date;
                                    ref
                                        .read(attendance_provider
                                            .studentAttendanceProvider.notifier)
                                        .state = {};
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Date',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: colorScheme.outline),
                                    ),
                                    suffixIcon: Icon(Icons.arrow_drop_down,
                                        color: colorScheme.primary),
                                    filled: true,
                                    fillColor: colorScheme.surfaceVariant
                                        .withOpacity(0.3),
                                  ),
                                  child: Text(
                                    DateFormat('MMM d, y').format(selectedDate),
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Lecture Selection
                        if (selectedClass != null)
                          Consumer(
                            builder: (context, ref, child) {
                              final timetableAsync = ref.watch(
                                attendance_provider
                                    .classTimetableProvider(selectedClass.id),
                              );

                              return timetableAsync.when(
                                data: (timetable) {
                                  if (timetable == null) {
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: colorScheme.errorContainer
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: colorScheme.errorContainer,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            color: colorScheme.error,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'No Timetable Available!',
                                                  style: TextStyle(
                                                    color: colorScheme.error,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Please create a timetable for this class first.',
                                                  style: TextStyle(
                                                    color: colorScheme
                                                        .onErrorContainer,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  final dayOfWeek = selectedDate.weekday - 1;

                                  // Get lectures for the selected day and ensure uniqueness
                                  final List<TimetableEntry> lectures = [];
                                  final Set<String> seenIds = {};

                                  for (var entry in timetable.entries) {
                                    if (entry.day == dayOfWeek &&
                                        !seenIds.contains(entry.id)) {
                                      lectures.add(entry);
                                      seenIds.add(entry.id);
                                    }
                                  }

                                  // Sort lectures by entry number
                                  lectures.sort((a, b) =>
                                      a.entryNumber.compareTo(b.entryNumber));

                                  if (lectures.isEmpty) {
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: colorScheme.tertiaryContainer
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: colorScheme.tertiaryContainer,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.event_busy,
                                            color: colorScheme.tertiary,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'No Lectures Scheduled',
                                                  style: TextStyle(
                                                    color: colorScheme.tertiary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'There are no lectures scheduled for this day. Please select a different date.',
                                                  style: TextStyle(
                                                    color: colorScheme
                                                        .onTertiaryContainer,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  // Reset selected lecture if it's not in the current list
                                  if (selectedLecture != null &&
                                      !lectures.any(
                                          (l) => l.id == selectedLecture!.id)) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      ref
                                          .read(attendance_provider
                                              .selectedLectureProvider.notifier)
                                          .state = null;
                                    });
                                  }

                                  return CustomDropdown<TimetableEntry>(
                                    label: 'Select Lecture',
                                    value: lectures.firstWhere(
                                      (l) => selectedLecture?.id == l.id,
                                      orElse: () => lectures.first,
                                    ),
                                    items: lectures.map((lecture) {
                                      String timeInfo = '';
                                      if (lecture.from != null &&
                                          lecture.to != null) {
                                        final startTime =
                                            TimeOfDay.fromDateTime(
                                                lecture.from!.toDate());
                                        final endTime = TimeOfDay.fromDateTime(
                                            lecture.to!.toDate());
                                        timeInfo =
                                            ' (${startTime.format(context)} - ${endTime.format(context)})';
                                      }

                                      return DropdownMenuItem(
                                        value: lecture,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 300),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.subject,
                                                  size: 18,
                                                  color: colorScheme.primary),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  '${lecture.subject}$timeInfo',
                                                  style: TextStyle(
                                                      color: colorScheme
                                                          .onSurface),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        ref
                                            .read(attendance_provider
                                                .selectedLectureProvider
                                                .notifier)
                                            .state = value;
                                        ref
                                            .read(attendance_provider
                                                .studentAttendanceProvider
                                                .notifier)
                                            .state = {};
                                      }
                                    },
                                    colorScheme: colorScheme,
                                    isExpanded: true,
                                  );
                                },
                                loading: () => const SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: LinearProgressIndicator(),
                                  ),
                                ),
                                error: (error, stack) => Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colorScheme.errorContainer,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: colorScheme.error,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Error Loading Timetable',
                                              style: TextStyle(
                                                color: colorScheme.error,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              error.toString(),
                                              style: TextStyle(
                                                color: colorScheme
                                                    .onErrorContainer,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Students List Header
                if (selectedClass != null && selectedLecture != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 8.0),
                    child: Text(
                      'Student Attendance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),

                // Students List
                if (selectedClass != null && selectedLecture != null)
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final studentsAsync = ref.watch(
                          attendance_provider
                              .classStudentsProvider(selectedClass.id),
                        );

                        return studentsAsync.when(
                          data: (students) {
                            if (students.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_off,
                                      size: 64,
                                      color: colorScheme.outline,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No students found in this class',
                                      style: TextStyle(
                                        color: colorScheme.outline,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Initialize attendance for all students as present if not already set
                            if (studentAttendance.isEmpty) {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) async {
                                // Try to fetch existing attendance
                                final existingAttendance = await ref.read(
                                  attendance_provider.lectureAttendanceProvider(
                                    (
                                      classId: selectedClass.id,
                                      timeTableEntryId: selectedLecture.id,
                                      date: selectedDate,
                                    ),
                                  ).future,
                                );

                                if (existingAttendance.isNotEmpty) {
                                  // If we found existing attendance, use it
                                  ref
                                      .read(attendance_provider
                                          .studentAttendanceProvider.notifier)
                                      .state = existingAttendance;
                                } else {
                                  // Otherwise, set all students as present
                                  final initialAttendance = {
                                    for (var student in students)
                                      student.id: true
                                  };
                                  ref
                                      .read(attendance_provider
                                          .studentAttendanceProvider.notifier)
                                      .state = initialAttendance;
                                }
                              });
                            }

                            return ListView.builder(
                              itemCount: students.length,
                              itemBuilder: (context, index) {
                                final student = students[index];
                                final isPresent =
                                    studentAttendance[student.id] ?? true;

                                final cardColor = isPresent
                                    ? colorScheme.tertiaryContainer
                                        .withOpacity(0.3)
                                    : colorScheme.errorContainer
                                        .withOpacity(0.3);

                                return Card(
                                  elevation: 0,
                                  color: cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 2),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          isPresent ? Colors.green : Colors.red,
                                      child: Text(
                                        student.name.isNotEmpty
                                            ? student.name[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      student.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    subtitle: Text(
                                      student.email,
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    trailing: Switch(
                                      value: isPresent,
                                      onChanged: (value) {
                                        ref
                                            .read(attendance_provider
                                                .studentAttendanceProvider
                                                .notifier)
                                            .state = {
                                          ...studentAttendance,
                                          student.id: value,
                                        };
                                      },
                                      activeColor: Colors.green,
                                      trackColor:
                                          MaterialStateProperty.resolveWith(
                                        (states) => states.contains(
                                                MaterialState.selected)
                                            ? Colors.green.withOpacity(0.5)
                                            : Colors.red.withOpacity(0.5),
                                      ),
                                      thumbColor:
                                          MaterialStateProperty.resolveWith(
                                        (states) => states.contains(
                                                MaterialState.selected)
                                            ? Colors.white
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, stack) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: $error',
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Save Button
                if (selectedClass != null && selectedLecture != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: FilledButton.tonal(
                      onPressed: () async {
                        if (currentUser == null) return;

                        final attendanceData =
                            studentAttendance.entries.map((entry) {
                          return {
                            'userId': entry.key,
                            'isPresent': entry.value,
                            'markedByUserId': currentUser.id,
                            'subject': selectedLecture.subject,
                          };
                        }).toList();

                        await ref
                            .read(
                                attendance_provider.attendanceProvider.notifier)
                            .markAttendance(
                              institutionId: currentUser.institutionId,
                              classId: selectedClass.id,
                              timeTableId: selectedLecture.id,
                              timeTableEntryId: selectedLecture.id,
                              attendanceData: attendanceData,
                            );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: colorScheme.onPrimary),
                                  const SizedBox(width: 8),
                                  const Text('Attendance marked successfully'),
                                ],
                              ),
                              backgroundColor: colorScheme.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save,
                              size: 20, color: colorScheme.onPrimaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            'Save Attendance',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
