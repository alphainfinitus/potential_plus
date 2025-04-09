import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/repositories/institution_class_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'attendance_provider.g.dart';

@riverpod
Future<Map<DateTime, List<Attendance>>> studentAttendance(
    StudentAttendanceRef ref) async {
  final appUser = ref.watch(authProvider).value;
  if (appUser == null || appUser.classId == null) {
    return {};
  }

  log('Fetching attendance for student: ${appUser.id}');

  // Get attendance for the last 6 months
  final now = DateTime.now();
  final sixMonthsAgo = DateTime(now.year, now.month - 6, 1);

  final attendanceMap = <DateTime, List<Attendance>>{};

  // Fetch attendance for each month
  for (int i = 0; i < 6; i++) {
    final date = DateTime(now.year, now.month - i, 1);
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);

    try {
      final attendances =
          await InstitutionClassRepository.fetchClassAttendanceByDate(
        institutionId: appUser.institutionId,
        institutionClassId: appUser.classId!,
        date: date,
      );

      // Filter attendances for the current student
      final studentAttendances = attendances
          .where((attendance) => attendance.userId == appUser.id)
          .toList();

      if (studentAttendances.isNotEmpty) {
        attendanceMap[date] = studentAttendances;
      }

      log('Fetched ${studentAttendances.length} attendance records for ${date.month}/${date.year}');
    } catch (e) {
      log('Error fetching attendance for ${date.month}/${date.year}: $e');
    }
  }

  return attendanceMap;
}

@riverpod
Future<Map<String, int>> attendanceStats(AttendanceStatsRef ref) async {
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
