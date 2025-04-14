import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/repositories/institution_class_repository.dart';
import 'package:potential_plus/repositories/teacher_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'attendance_provider.g.dart';

@riverpod
Future<Map<DateTime, List<Attendance>>> studentAttendance(Ref ref) async {
  final appUser = ref.watch(authProvider).value;
  if (appUser == null || appUser.classId == null) {
    return {};
  }

  return TeacherRepository.fetchStudentAttendance(appUser.id);
}

@riverpod
class AttendanceNotifier extends _$AttendanceNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> markAttendance({
    required String studentId,
    required bool isPresent,
    required String institutionId,
    required String classId,
  }) async {
    final teacher = ref.read(authProvider).value;
    if (teacher == null) throw Exception('Not authenticated');

    await TeacherRepository.updateStudentAttendance(
      studentId: studentId,
      isPresent: isPresent,
      institutionId: institutionId,
      markedByUserId: teacher.id,
      classId: classId,
    );

    // Create activity record
    final activity = {
      'teacherId': teacher.id,
      'type': 'attendance',
      'title': 'Attendance Marked',
      'description': 'Marked attendance for student $studentId',
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('activities').add(activity);
  }
}

@riverpod
Future<Map<String, int>> attendanceStats(Ref ref) async {
  final attendances = await ref.watch(studentAttendanceProvider.future);

  int totalClasses = 0;
  int presentCount = 0;
  int absentCount = 0;

  attendances.forEach((date, attendanceList) {
    totalClasses += attendanceList.length;
    presentCount += attendanceList.where((a) => a.isPresent).length;
    absentCount += attendanceList.where((a) => !a.isPresent).length;
  });

  return {
    'totalClasses': totalClasses,
    'present': presentCount,
    'absent': absentCount,
    'percentage':
        totalClasses > 0 ? (presentCount / totalClasses * 100).round() : 0,
  };
}
