import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart'
    as attendance_provider;
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/widgets/custom_dropdown.dart';
import 'package:potential_plus/theme/input_decorations.dart';
import 'package:intl/intl.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart'
    show AttendanceParams;

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClass = ref.watch(attendance_provider.selectedClassProvider);
    final selectedDate = ref.watch(attendance_provider.selectedDateProvider);
    final selectedLecture =
        ref.watch(attendance_provider.selectedLectureProvider);
    final studentAttendance =
        ref.watch(attendance_provider.attendanceStateProvider);
    final classesAsync = ref.watch(classesProvider);
    final currentUser = ref.watch(authProvider).value;

    final colorScheme = Theme.of(context).colorScheme;

    ref.watch(attendance_provider.attendanceWatcherProvider);

    if (selectedClass != null && selectedLecture != null) {
      ref.listen(
        attendance_provider.lectureAttendanceProvider(AttendanceParams(
          classId: selectedClass.id,
          timeTableEntryId: selectedLecture.id,
          date: selectedDate,
        )),
        (previous, next) {
          next.whenData((attendanceMap) {
            ref
                .read(attendance_provider.attendanceStateProvider.notifier)
                .state = attendanceMap;
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
              colorScheme.primaryContainer.withOpacity(0.2),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class Information Header
                Text(
                  'Class Information',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                // Class and Date Selection Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Class Selection
                    Expanded(
                      child: classesAsync.when(
                        data: (classes) => CustomDropdown<InstitutionClass>(
                          label: 'Class',
                          value: selectedClass,
                          items: classes!.map((cls) {
                            return DropdownMenuItem(
                              value: cls,
                              child: Text(
                                cls.name,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 13,
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
                                    .selectedLectureProvider.notifier)
                                .state = null;
                          },
                          colorScheme: colorScheme,
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: colorScheme.error, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Error loading classes: $error',
                                  style: TextStyle(
                                      color: colorScheme.error, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                          }
                        },
                        child: InputDecorator(
                          decoration: SharedInputDecorations.getDropdown(
                            context: context,
                            labelText: 'Date',
                            iconColor: colorScheme.primary,
                          ),
                          child: Text(
                            DateFormat('MMM d, y').format(selectedDate),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.errorContainer.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colorScheme.errorContainer,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.schedule,
                                      color: colorScheme.error, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'No timetable available for this class',
                                      style: TextStyle(
                                        color: colorScheme.error,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final dayOfWeek = selectedDate.weekday - 1;
                          final lectures = timetable.entries
                              .where((entry) => entry.day == dayOfWeek)
                              .toList();

                          if (lectures.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.tertiaryContainer
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colorScheme.tertiaryContainer,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.event_busy,
                                      color: colorScheme.tertiary, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'No lectures scheduled for this day',
                                      style: TextStyle(
                                        color: colorScheme.tertiary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return CustomDropdown<TimetableEntry>(
                            label: 'Select Lecture',
                            value: lectures.firstWhere(
                              (l) => selectedLecture?.id == l.id,
                              orElse: () => lectures.first,
                            ),
                            items: lectures.map((lecture) {
                              String timeInfo = '';
                              if (lecture.from != null && lecture.to != null) {
                                final startTime = TimeOfDay.fromDateTime(
                                    lecture.from!.toDate());
                                final endTime = TimeOfDay.fromDateTime(
                                    lecture.to!.toDate());
                                timeInfo =
                                    ' (${startTime.format(context)} - ${endTime.format(context)})';
                              }

                              return DropdownMenuItem(
                                value: lecture,
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 300),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.subject,
                                          size: 16, color: colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${lecture.subject}$timeInfo',
                                          style: TextStyle(
                                              color: colorScheme.onSurface,
                                              fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
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
                                        .selectedLectureProvider.notifier)
                                    .state = value;
                              }
                            },
                            colorScheme: colorScheme,
                            isExpanded: true,
                          );
                        },
                        loading: () => const SizedBox(
                          height: 40,
                          child: Center(child: LinearProgressIndicator()),
                        ),
                        error: (error, stack) => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorScheme.errorContainer,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: colorScheme.error, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Error loading timetable',
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 12),

                // Students List Header and List - Only show if there are lectures
                if (selectedClass != null && selectedLecture != null)
                  Consumer(
                    builder: (context, ref, child) {
                      final timetableAsync = ref.watch(
                        attendance_provider
                            .classTimetableProvider(selectedClass.id),
                      );

                      return timetableAsync.when(
                        data: (timetable) {
                          if (timetable == null) return const SizedBox.shrink();

                          final dayOfWeek = selectedDate.weekday - 1;
                          final lectures = timetable.entries
                              .where((entry) => entry.day == dayOfWeek)
                              .toList();

                          if (lectures.isEmpty) return const SizedBox.shrink();

                          return Expanded(
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.person_off,
                                                size: 48,
                                                color: colorScheme.outline),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Students List Header
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0, vertical: 4.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Student Attendance',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Mark All Section
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: colorScheme
                                                      .surfaceVariant
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // Mark All Present
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Checkbox(
                                                          value: students.every(
                                                              (student) =>
                                                                  studentAttendance[
                                                                      student
                                                                          .id] ==
                                                                  true),
                                                          onChanged: (value) {
                                                            if (value == true) {
                                                              final newAttendance = Map<
                                                                      String,
                                                                      bool>.fromEntries(
                                                                  students.map((student) =>
                                                                      MapEntry(
                                                                          student
                                                                              .id,
                                                                          true)));
                                                              ref
                                                                  .read(attendance_provider
                                                                      .attendanceStateProvider
                                                                      .notifier)
                                                                  .state = newAttendance;
                                                            }
                                                          },
                                                          activeColor:
                                                              Colors.green,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                        ),
                                                        Text(
                                                          'Mark All Present',
                                                          style: TextStyle(
                                                            color: colorScheme
                                                                .onSurface,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 16),
                                                    // Mark All Absent
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Checkbox(
                                                          value: students.every(
                                                              (student) =>
                                                                  studentAttendance[
                                                                      student
                                                                          .id] ==
                                                                  false),
                                                          onChanged: (value) {
                                                            if (value == true) {
                                                              final newAttendance = Map<
                                                                      String,
                                                                      bool>.fromEntries(
                                                                  students.map((student) =>
                                                                      MapEntry(
                                                                          student
                                                                              .id,
                                                                          false)));
                                                              ref
                                                                  .read(attendance_provider
                                                                      .attendanceStateProvider
                                                                      .notifier)
                                                                  .state = newAttendance;
                                                            }
                                                          },
                                                          activeColor:
                                                              Colors.red,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                        ),
                                                        Text(
                                                          'Mark All Absent',
                                                          style: TextStyle(
                                                            color: colorScheme
                                                                .onSurface,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
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
                                              final isPresent =
                                                  studentAttendance[student.id];

                                              final cardColor = isPresent ==
                                                      null
                                                  ? colorScheme.surfaceVariant
                                                      .withOpacity(0.1)
                                                  : isPresent
                                                      ? colorScheme
                                                          .tertiaryContainer
                                                          .withOpacity(0.2)
                                                      : colorScheme
                                                          .errorContainer
                                                          .withOpacity(0.2);

                                              return Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: cardColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: ListTile(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 4),
                                                  leading: CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor:
                                                        isPresent == null
                                                            ? colorScheme
                                                                .outline
                                                            : isPresent
                                                                ? Colors.green
                                                                : Colors.red,
                                                    child: Text(
                                                      student.name.isNotEmpty
                                                          ? student.name[0]
                                                              .toUpperCase()
                                                          : '?',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    student.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          colorScheme.onSurface,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      // Present Checkbox
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Checkbox(
                                                            value: isPresent ==
                                                                true,
                                                            onChanged: (value) {
                                                              if (value ==
                                                                  true) {
                                                                ref
                                                                    .read(attendance_provider
                                                                        .attendanceStateProvider
                                                                        .notifier)
                                                                    .state = {
                                                                  ...studentAttendance,
                                                                  student.id:
                                                                      true,
                                                                };
                                                              }
                                                            },
                                                            activeColor:
                                                                Colors.green,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                          ),
                                                          Text(
                                                            'Present',
                                                            style: TextStyle(
                                                              color: colorScheme
                                                                  .onSurface,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 8),
                                                      // Absent Checkbox
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Checkbox(
                                                            value: isPresent ==
                                                                false,
                                                            onChanged: (value) {
                                                              if (value ==
                                                                  true) {
                                                                ref
                                                                    .read(attendance_provider
                                                                        .attendanceStateProvider
                                                                        .notifier)
                                                                    .state = {
                                                                  ...studentAttendance,
                                                                  student.id:
                                                                      false,
                                                                };
                                                              }
                                                            },
                                                            activeColor:
                                                                Colors.red,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                          ),
                                                          Text(
                                                            'Absent',
                                                            style: TextStyle(
                                                              color: colorScheme
                                                                  .onSurface,
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
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (error, stack) => Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error_outline,
                                            size: 48, color: colorScheme.error),
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
                              },
                            ),
                          );
                        },
                        loading: () => const SizedBox(
                          height: 40,
                          child: Center(child: LinearProgressIndicator()),
                        ),
                        error: (error, stack) => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorScheme.errorContainer,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: colorScheme.error, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Error loading timetable',
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontSize: 13,
                                  ),
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
      ),
      floatingActionButton: selectedClass != null && selectedLecture != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                if (currentUser == null) return;

                final studentsAsync = ref.read(attendance_provider
                    .classStudentsProvider(selectedClass.id));
                final students = studentsAsync.value ?? [];
                if (students.isEmpty) return;

                final controller = ref.read(attendance_provider
                    .attendanceControllerProvider(AttendanceParams(
                  classId: selectedClass.id,
                  timeTableEntryId: selectedLecture.id,
                  date: selectedDate,
                )));
                if (controller == null) return;

                await controller.markAttendance(
                  students,
                  studentAttendance,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: colorScheme.onPrimary, size: 20),
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
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              icon: Icon(Icons.save, size: 18),
              label: const Text('Save Attendance'),
            )
          : null,
    );
  }
}
