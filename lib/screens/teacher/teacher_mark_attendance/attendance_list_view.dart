import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/repositories/teacher_repository.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/repositories/institution_class_repository.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/utils.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart';

class AttendanceListView extends ConsumerStatefulWidget {
  const AttendanceListView({super.key, required this.institutionClass});

  final InstitutionClass institutionClass;

  @override
  ConsumerState<AttendanceListView> createState() => _AttendanceListViewState();
}

class _AttendanceListViewState extends ConsumerState<AttendanceListView> {
  Map<String, bool> attendanceMap = {};
  Map<String, bool> pendingUpdates = {};
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    setState(() {
      isLoading = true;
    });

    try {
      final institution = ref.read(institutionProvider).value!;
      final List<Attendance> attendanceList =
          await InstitutionClassRepository.fetchClassAttendanceByDate(
        institutionId: institution.id,
        institutionClassId: widget.institutionClass.id,
        date: DateTime.now(),
      );

      setState(() {
        attendanceMap = {
          for (var attendance in attendanceList)
            attendance.userId: attendance.isPresent
        };
        pendingUpdates = {};
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch attendance: $e')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _markAll(bool isPresent) {
    setState(() {
      final students =
          ref.read(classStudentsProvider(widget.institutionClass.id)).value;
      if (students != null) {
        for (var student in students.values) {
          pendingUpdates[student.id] = isPresent;
        }
      }
    });
  }

  Future<void> _submitAttendance() async {
    if (pendingUpdates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to submit')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final institution = ref.read(institutionProvider).value!;
      final teacher = ref.read(authProvider).value!;

      for (var entry in pendingUpdates.entries) {
        await ref.read(attendanceNotifierProvider.notifier).markAttendance(
              studentId: entry.key,
              isPresent: entry.value,
              institutionId: institution.id,
              classId: widget.institutionClass.id,
            );
      }

      setState(() {
        attendanceMap.addAll(pendingUpdates);
        pendingUpdates.clear();
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance updated successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating attendance: $e')),
        );
      }
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final InstitutionClass institutionClass = widget.institutionClass;
    final Map<String, AppUser>? students =
        ref.watch(classStudentsProvider(institutionClass.id)).value;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (students == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (students.isEmpty) {
      return Center(
          child: Text('No students found for ${institutionClass.name}'));
    }

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${students.length} Students',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Attendance for ${AppUtils.formatDate(DateTime.now())}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                        ),
                      ],
                    ),
                    if (pendingUpdates.isNotEmpty)
                      Text(
                        '${pendingUpdates.length} changes pending',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _markAll(true),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Mark All Present'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _markAll(false),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Mark All Absent'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students.values.elementAt(index);
              final bool isPresent = pendingUpdates[student.id] ??
                  attendanceMap[student.id] ??
                  false;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(student.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Present'),
                      Radio<bool>(
                        value: true,
                        groupValue: isPresent,
                        onChanged: (bool? value) {
                          setState(() {
                            pendingUpdates[student.id] = value ?? false;
                          });
                        },
                      ),
                      const Text('Absent'),
                      Radio<bool>(
                        value: false,
                        groupValue: isPresent,
                        onChanged: (bool? value) {
                          setState(() {
                            pendingUpdates[student.id] = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (pendingUpdates.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _submitAttendance,
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Attendance'),
            ),
          ),
      ],
    );
  }
}
