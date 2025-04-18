import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart';
import 'package:potential_plus/utils.dart';

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  const MarkAttendanceScreen({
    super.key,
    required this.institutionClass,
  });

  final InstitutionClass institutionClass;

  @override
  ConsumerState<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  final Map<String, bool> attendanceStatus = {};
  bool isSaving = false;
  bool isLoading = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeAttendanceStatus();
  }

  Future<void> _loadAttendanceForDate() async {
    setState(() {
      isLoading = true;
    });

    try {
      final students =
          ref.read(classStudentsProvider(widget.institutionClass.id)).value;
      if (students == null) return;

      // Reset all attendance status to true (default)
      for (var student in students.values) {
        attendanceStatus[student.id] = true;
      }

      // Fetch attendance for the selected date
      final startOfDay = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      final endOfDay = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        23,
        59,
        59,
      );

      final snapshot = await FirebaseFirestore.instance
          .collection('attendances')
          .where('classId', isEqualTo: widget.institutionClass.id)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('createdAt', isLessThanOrEqualTo: endOfDay)
          .get();

      // Update attendance status based on existing records
      for (var doc in snapshot.docs) {
        final attendance = Attendance.fromFirestore(doc);
        attendanceStatus[attendance.userId] = attendance.isPresent;
      }
    } catch (e) {
      debugPrint('Error loading attendance: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _initializeAttendanceStatus() {
    final students =
        ref.read(classStudentsProvider(widget.institutionClass.id)).value;
    if (students != null) {
      for (var student in students.values) {
        attendanceStatus[student.id] = true; // Default to present
      }
      _loadAttendanceForDate();
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
      await _loadAttendanceForDate();
    }
  }

  Future<void> _saveAttendance() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final institution = ref.read(institutionProvider).value!;
      final students =
          ref.read(classStudentsProvider(widget.institutionClass.id)).value;

      if (students == null) {
        debugPrint('Error: Students list is null');
        return;
      }

      debugPrint('Starting to mark attendance for ${students.length} students');
      debugPrint('Institution ID: ${institution.id}');
      debugPrint('Class ID: ${widget.institutionClass.id}');
      debugPrint('Date: ${selectedDate}');

      // Mark attendance for each student
      for (var student in students.values) {
        final isPresent = attendanceStatus[student.id] ?? true;
        debugPrint(
            'Marking attendance for student ${student.id}: ${isPresent ? 'Present' : 'Absent'}');

        try {
          await ref.read(attendanceNotifierProvider.notifier).markAttendance(
                studentId: student.id,
                isPresent: isPresent,
                institutionId: institution.id,
                classId: widget.institutionClass.id,
                date: selectedDate,
              );
          debugPrint(
              'Successfully marked attendance for student ${student.id}');
        } catch (e) {
          debugPrint('Error marking attendance for student ${student.id}: $e');
          rethrow;
        }
      }

      debugPrint('Successfully marked attendance for all students');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance marked successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _saveAttendance: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark attendance: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final students =
        ref.watch(classStudentsProvider(widget.institutionClass.id)).value;

    if (students == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        actions: [
          if (isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveAttendance,
            ),
        ],
      ),
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
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: ListTile(
                      title: Text(student.name),
                      trailing: Switch(
                        value: attendanceStatus[student.id] ?? true,
                        onChanged: (value) {
                          setState(() {
                            attendanceStatus[student.id] = value;
                          });
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
