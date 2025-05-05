import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart'
    as attendance_provider;
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/widgets/custom_dropdown.dart';
import 'package:intl/intl.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart'
    show AttendanceParams;

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize attendance state when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedClass = ref.read(attendance_provider.selectedClassProvider);
      final selectedLecture =
          ref.read(attendance_provider.selectedLectureProvider);
      final selectedDate = ref.read(attendance_provider.selectedDateProvider);
      if (selectedClass != null && selectedLecture != null) {
        ref
            .read(attendance_provider.attendanceStateProvider.notifier)
            .fetchAndUpdateAttendance(
              classId: selectedClass.id,
              timeTableEntryId: selectedLecture.id,
              date: selectedDate,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedClass = ref.watch(attendance_provider.selectedClassProvider);
    final selectedDate = ref.watch(attendance_provider.selectedDateProvider);
    final selectedLecture =
        ref.watch(attendance_provider.selectedLectureProvider);
    final attendanceState =
        ref.watch(attendance_provider.attendanceStateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Selection
            CustomDropdown<InstitutionClass>(
              value: selectedClass,
              items: ref.watch(classesProvider).when(
                    data: (classes) =>
                        classes
                            ?.map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.name),
                                ))
                            .toList() ??
                        [],
                    loading: () => const [],
                    error: (_, __) => const [],
                  ),
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(attendance_provider.selectedClassProvider.notifier)
                      .state = value;
                  ref
                      .read(
                          attendance_provider.selectedLectureProvider.notifier)
                      .state = null;
                }
              },
              label: 'Select Class',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),

            // Date Selection
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: 'Select Date',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              readOnly: true,
              controller: TextEditingController(
                text: DateFormat('dd/MM/yyyy').format(selectedDate),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2025),
                );
                if (date != null) {
                  ref
                      .read(attendance_provider.selectedDateProvider.notifier)
                      .state = date;
                }
              },
            ),
            const SizedBox(height: 16),

            // Lecture Selection
            if (selectedClass != null)
              CustomDropdown<TimetableEntry>(
                value: selectedLecture,
                items: ref
                    .watch(attendance_provider
                        .classTimetableProvider(selectedClass.id))
                    .when(
                      data: (timetable) =>
                          timetable?.entries
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.subject),
                                  ))
                              .toList() ??
                          [],
                      loading: () => const [],
                      error: (_, __) => const [],
                    ),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(attendance_provider
                            .selectedLectureProvider.notifier)
                        .state = value;
                  }
                },
                label: 'Select Lecture',
                colorScheme: colorScheme,
              ),
            const SizedBox(height: 24),

            // Student List
            if (selectedClass != null && selectedLecture != null)
              Expanded(
                child: ref
                    .watch(attendance_provider
                        .classStudentsProvider(selectedClass.id))
                    .when(
                      data: (students) => ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return CheckboxListTile(
                            title: Text(student.name),
                            subtitle: Text(
                                student.id), // Using ID as roll number for now
                            value: attendanceState[student.id] ?? false,
                            onChanged: (bool? value) {
                              if (value != null) {
                                ref
                                    .read(attendance_provider
                                        .attendanceStateProvider.notifier)
                                    .updateAttendance(
                                      student.id,
                                      value,
                                    );
                              }
                            },
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text('Error loading students: $error'),
                      ),
                    ),
              ),

            // Submit Button
            if (selectedClass != null && selectedLecture != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final students = await ref.read(attendance_provider
                            .classStudentsProvider(selectedClass.id)
                            .future);
                        final controller = ref.read(attendance_provider
                            .attendanceControllerProvider(AttendanceParams(
                          classId: selectedClass.id,
                          timeTableEntryId: selectedLecture.id,
                          date: selectedDate,
                        )));

                        if (controller != null) {
                          await controller.markAttendance(
                              students, attendanceState);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Attendance marked successfully')),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Failed to mark attendance: ${e.toString()}')),
                          );
                        }
                      }
                    },
                    child: const Text('Submit Attendance'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
