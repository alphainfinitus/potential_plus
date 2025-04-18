import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/repositories/institution_class_repository.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/screens/teacher/teacher_mark_attendance/mark_attendance_screen.dart';
import 'package:potential_plus/utils.dart';
import 'package:potential_plus/providers/attendance_provider.dart';

class AttendanceListView extends ConsumerStatefulWidget {
  const AttendanceListView({
    super.key,
    required this.institutionClass,
  });

  final InstitutionClass institutionClass;

  @override
  ConsumerState<AttendanceListView> createState() => _AttendanceListViewState();
}

class _AttendanceListViewState extends ConsumerState<AttendanceListView> {
  Map<String, List<Attendance>> attendanceMap = {};
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();

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
      print('Fetching attendance for institution: ${institution.id}');
      print('Class ID: ${widget.institutionClass.id}');
      print('Date: $selectedDate');

      final List<Attendance> attendanceList =
          await InstitutionClassRepository.fetchClassAttendanceByDate(
        institutionId: institution.id,
        institutionClassId: widget.institutionClass.id,
        date: selectedDate,
      );

      print('Fetched ${attendanceList.length} attendance records');

      // Group attendance by student
      final Map<String, List<Attendance>> groupedAttendance = {};
      for (var attendance in attendanceList) {
        print('Processing attendance for student: ${attendance.userId}');
        groupedAttendance
            .putIfAbsent(attendance.userId, () => [])
            .add(attendance);
      }

      print('Grouped attendance into ${groupedAttendance.length} students');

      setState(() {
        attendanceMap = groupedAttendance;
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await _fetchAttendance();
    }
  }

  Future<void> _showEditAttendanceDialog(BuildContext context, AppUser student,
      List<Attendance> attendances) async {
    await showDialog(
      context: context,
      builder: (context) => EditAttendanceDialog(
        student: student,
        attendances: attendances,
        onAttendanceUpdated: () => _fetchAttendance(),
      ),
    );
  }

  Widget _buildAttendanceDots(List<Attendance> attendances) {
    return Row(
      children: [
        Text('${AppUtils.formatDate(selectedDate)} Attendance: '),
        ...attendances.map((attendance) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: attendance.isPresent ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final students =
        ref.watch(classStudentsProvider(widget.institutionClass.id)).value;

    if (students == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              title: const Text('Select Date'),
              subtitle: Text(AppUtils.formatDate(selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students.values.elementAt(index);
                  final attendances = attendanceMap[student.id] ?? [];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: InkWell(
                      onTap: () => _showEditAttendanceDialog(
                          context, student, attendances),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (attendances.isEmpty)
                              const Text(
                                'No attendance marked for this date',
                                style: TextStyle(color: Colors.grey),
                              )
                            else
                              _buildAttendanceDots(attendances),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MarkAttendanceScreen(
                institutionClass: widget.institutionClass,
              ),
            ),
          ).then((_) => _fetchAttendance());
        },
        tooltip: 'Add Attendance',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddAttendanceDialog extends StatefulWidget {
  const AddAttendanceDialog({super.key});

  @override
  State<AddAttendanceDialog> createState() => _AddAttendanceDialogState();
}

class _AddAttendanceDialogState extends State<AddAttendanceDialog> {
  bool isPresent = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Attendance'),
      content: Row(
        children: [
          const Text('Status: '),
          const Text('Present'),
          Radio<bool>(
            value: true,
            groupValue: isPresent,
            onChanged: (bool? value) {
              setState(() {
                isPresent = value ?? true;
              });
            },
          ),
          const Text('Absent'),
          Radio<bool>(
            value: false,
            groupValue: isPresent,
            onChanged: (bool? value) {
              setState(() {
                isPresent = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, isPresent);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class EditAttendanceDialog extends ConsumerWidget {
  const EditAttendanceDialog({
    super.key,
    required this.student,
    required this.attendances,
    required this.onAttendanceUpdated,
  });

  final AppUser student;
  final List<Attendance> attendances;
  final VoidCallback onAttendanceUpdated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _EditAttendanceDialogContent(
      student: student,
      attendances: attendances,
      onAttendanceUpdated: onAttendanceUpdated,
    );
  }
}

class _EditAttendanceDialogContent extends ConsumerStatefulWidget {
  const _EditAttendanceDialogContent({
    required this.student,
    required this.attendances,
    required this.onAttendanceUpdated,
  });

  final AppUser student;
  final List<Attendance> attendances;
  final VoidCallback onAttendanceUpdated;

  @override
  ConsumerState<_EditAttendanceDialogContent> createState() =>
      _EditAttendanceDialogState();
}

class _EditAttendanceDialogState
    extends ConsumerState<_EditAttendanceDialogContent> {
  bool isLoading = false;
  Map<String, bool> pendingUpdates = {};

  Future<void> _updateAttendance(Attendance attendance, bool isPresent) async {
    setState(() {
      pendingUpdates[attendance.id] = isPresent;
    });
  }

  Future<void> _saveAllUpdates() async {
    if (pendingUpdates.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      for (var entry in pendingUpdates.entries) {
        await ref.read(attendanceNotifierProvider.notifier).updateAttendance(
              attendanceId: entry.key,
              isPresent: entry.value,
            );
      }

      // Refresh the parent widget's attendance data
      widget.onAttendanceUpdated();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update attendance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          pendingUpdates.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Attendance - ${widget.student.name}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (widget.attendances.isEmpty)
              const Text('No attendance records found')
            else
              ...widget.attendances.map((attendance) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(AppUtils.formatDate(attendance.createdAt)),
                      subtitle: Text(AppUtils.formatTime(attendance.createdAt)),
                      trailing: Switch(
                        value: pendingUpdates.containsKey(attendance.id)
                            ? pendingUpdates[attendance.id]!
                            : attendance.isPresent,
                        onChanged: isLoading
                            ? null
                            : (value) => _updateAttendance(attendance, value),
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                      ),
                    ),
                  )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading || pendingUpdates.isEmpty
              ? null
              : () => _saveAllUpdates(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
