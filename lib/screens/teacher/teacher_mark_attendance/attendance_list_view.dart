import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/auth_provider.dart';
import 'package:potential_plus/providers/institution_provider.dart';
import 'package:potential_plus/providers/students_provider.dart';
import 'package:potential_plus/providers/teachers_provider.dart';

class AttendanceListView extends ConsumerStatefulWidget {
  const AttendanceListView({super.key, required this.institutionClass});

  final InstitutionClass institutionClass;

  @override
  ConsumerState<AttendanceListView> createState() => _AttendanceListViewState();
}

class _AttendanceListViewState extends ConsumerState<AttendanceListView> {
  Map<String, bool> attendanceMap = {};

  void _handleAttendanceChange(String studentId, bool? value) {
    setState(() {
      attendanceMap[studentId] = value ?? false;
    });
    updateStudentAttendance(
      studentId: studentId,
      isPresent: value ?? false,
      institutionId: ref.watch(institutionProvider).value!.id,
      markedByUserId: ref.watch(authProvider).value!.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final InstitutionClass institutionClass = widget.institutionClass;
    final Map<String, AppUser>? students = ref.watch(studentsProvider).value;

    if (students == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (students.isEmpty) {
      return Center(child: Text('No students found for ${institutionClass.name}'));
    }

    return ListView.builder(
      itemCount: students.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final student = students.values.elementAt(index);
        return ListTile(
          title: Text(student.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Present'),
              Radio<bool>(
                value: true,
                groupValue: attendanceMap[student.id] ?? false,
                onChanged: (bool? value) => _handleAttendanceChange(student.id, value),
              ),
              const Text('Absent'),
              Radio<bool>(
                value: false,
                groupValue: attendanceMap[student.id] ?? false,
                onChanged: (bool? value) => _handleAttendanceChange(student.id, value),
              ),
            ],
          ),
        );
      },
    );
  }
}
