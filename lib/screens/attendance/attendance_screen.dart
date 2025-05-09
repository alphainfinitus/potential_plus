
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/screens/attendance/widgets/class_selection_widget.dart';
import 'package:potential_plus/screens/attendance/widgets/date_selection_widget.dart';
import 'package:potential_plus/screens/attendance/widgets/lecture_selection_widget.dart';
import 'package:potential_plus/screens/attendance/widgets/student_list_widget.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeAttendanceState();
      _isInitialized = true;
    }
  }

  void _initializeAttendanceState() {
    final selectedClass = ref.read(selectedClassProvider);
    final selectedLecture = ref.read(selectedLectureProvider);
    final selectedDate = ref.read(selectedDateProvider);

    if (selectedClass != null && selectedLecture != null) {
      ref
          .read(lectureAttendanceProvider(AttendanceParams(
        classId: selectedClass.id,
        timeTableEntryId: selectedLecture.id,
        date: selectedDate,
      )))
          .whenData((attendanceMap) {
        if (attendanceMap.isNotEmpty) {
          ref.read(attendanceStateProvider.notifier).state = attendanceMap;
        } else {
          ref.read(attendanceStateProvider.notifier).fetchAndUpdateAttendance(
                classId: selectedClass.id,
                timeTableEntryId: selectedLecture.id,
                date: selectedDate,
              );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedClass = ref.watch(selectedClassProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedLecture = ref.watch(selectedLectureProvider);
    final studentAttendance = ref.watch(attendanceStateProvider);
    final currentUser = ref.watch(authProvider).value;

    // Watch the attendance watcher
    ref.watch(attendanceWatcherProvider);

    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(selectedClassProvider, (previous, next) {
      if (next != null) {
        _initializeAttendanceState();
      }
    });

    ref.listen(selectedLectureProvider, (previous, next) {
      if (next != null) {
        _initializeAttendanceState();
      }
    });

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
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: ClassSelectionWidget()),
                    SizedBox(width: 8),
                    Expanded(child: DateSelectionWidget()),
                  ],
                ),
                const SizedBox(height: 12),

                // Lecture Selection
                const LectureSelectionWidget(),
                const SizedBox(height: 12),

                // Students List
                if (selectedClass != null && selectedLecture != null)
                  const Expanded(child: StudentListWidget()),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: selectedClass != null && selectedLecture != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                if (currentUser == null) return;

                final studentsAsync =
                    ref.read(classStudentsProvider(selectedClass.id));
                final students = studentsAsync.value ?? [];
                if (students.isEmpty) return;

                final controller =
                    ref.read(attendanceControllerProvider(AttendanceParams(
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
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Save Attendance'),
            )
          : null,
    );
  }
}
