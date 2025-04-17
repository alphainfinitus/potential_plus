import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeAttendanceStatus();
  }

  void _initializeAttendanceStatus() {
    final students =
        ref.read(classStudentsProvider(widget.institutionClass.id)).value;
    if (students != null) {
      for (var student in students.values) {
        attendanceStatus[student.id] = true; // Default to present
      }
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
        print('Error: Students list is null');
        return;
      }

      print('Starting to mark attendance for ${students.length} students');
      print('Institution ID: ${institution.id}');
      print('Class ID: ${widget.institutionClass.id}');

      // Mark attendance for each student
      for (var student in students.values) {
        final isPresent = attendanceStatus[student.id] ?? true;
        print(
            'Marking attendance for student ${student.id}: ${isPresent ? 'Present' : 'Absent'}');

        try {
          await ref.read(attendanceNotifierProvider.notifier).markAttendance(
                studentId: student.id,
                isPresent: isPresent,
                institutionId: institution.id,
                classId: widget.institutionClass.id,
              );
          print('Successfully marked attendance for student ${student.id}');
        } catch (e) {
          print('Error marking attendance for student ${student.id}: $e');
          rethrow;
        }
      }

      print('Successfully marked attendance for all students');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance marked successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      print('Error in _saveAttendance: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark attendance: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
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
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students.values.elementAt(index);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
    );
  }
}
