import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user/app_user.dart';
import 'package:potential_plus/models/app_user/teacher_repository.dart';
import 'package:potential_plus/models/institution_class/institution_class.dart';
import 'package:potential_plus/models/attendance/attendance.dart';
import 'package:potential_plus/models/institution_class/institution_class_repository.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/providers/students_provider/students_provider.dart';

class AttendanceListView extends ConsumerStatefulWidget {
  const AttendanceListView({super.key, required this.institutionClass});

  final InstitutionClass institutionClass;

  @override
  ConsumerState<AttendanceListView> createState() => _AttendanceListViewState();
}

class _AttendanceListViewState extends ConsumerState<AttendanceListView> {
  Map<String, bool> attendanceMap = {};
  Map<String, bool> loadingStates = {};
  bool isLoading = true;

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
      final List<Attendance> attendanceList = await InstitutionClassRepository.fetchClassAttendanceByDate(
        institution.id,
        widget.institutionClass.id,
        DateTime.now(),
      );

      setState(() {
        attendanceMap = {
          for (var attendance in attendanceList)
            attendance.userId: attendance.isPresent
        };
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch attendance: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleAttendanceChange(String studentId, bool? value) async {
    setState(() {
      loadingStates[studentId] = true;
    });

    try {
      await TeacherRepository.updateStudentAttendance(
        studentId: studentId,
        isPresent: value ?? false,
        institutionId: ref.read(institutionProvider).value!.id,
        markedByUserId: ref.read(authProvider).value!.id,
      );

      setState(() {
        attendanceMap[studentId] = value ?? false;
      });
    } catch (e) {
      // Handle error (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update attendance: $e')),
      );
    } finally {
      setState(() {
        loadingStates[studentId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final InstitutionClass institutionClass = widget.institutionClass;
    final Map<String, AppUser>? students = ref.watch(studentsProvider).value;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
        final bool isLoading = loadingStates[student.id] ?? false;

        return ListTile(
          title: Text(student.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Present'),
              Radio<bool>(
                value: true,
                groupValue: attendanceMap[student.id] ?? false,
                onChanged: isLoading ? null : (bool? value) => _handleAttendanceChange(student.id, value),
              ),
              const Text('Absent'),
              Radio<bool>(
                value: false,
                groupValue: attendanceMap[student.id] ?? false,
                onChanged: isLoading ? null : (bool? value) => _handleAttendanceChange(student.id, value),
              ),
            ],
          ),
        );
      },
    );
  }
}
