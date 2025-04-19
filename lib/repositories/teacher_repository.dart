import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:potential_plus/constants/activity_type.dart';
import 'package:potential_plus/models/activity/activity.dart';
import 'package:potential_plus/models/activity/attendance_activity.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/services/db_service.dart';

class TeacherRepository {
  static Future<Map<DateTime, List<Attendance>>> fetchStudentAttendance(
      String studentId) async {
    final now = DateTime.now();
    final attendanceMap = <DateTime, List<Attendance>>{};

    // Fetch attendance for the last 6 months
    for (int i = 0; i < 6; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final snapshot = await FirebaseFirestore.instance
          .collection('attendances')
          .where('userId', isEqualTo: studentId)
          .where('createdAt', isGreaterThanOrEqualTo: date)
          .where('createdAt',
              isLessThan: DateTime(date.year, date.month + 1, 1))
          .get();
      final attendances =
          snapshot.docs.map((doc) => Attendance.fromFirestore(doc)).toList();

      if (attendances.isNotEmpty) {
        attendanceMap[date] = attendances;
      }
    }
    return attendanceMap;
  }

  static Future updateStudentAttendance({
    required String studentId,
    required bool isPresent,
    required String institutionId,
    required AppUser markedByUserId,
    required InstitutionClass institutionClass,
    DateTime? date,
  }) async {
    try {
      final newAttendanceDoc = DbService.attendancesCollRef().doc();
      final attendanceDate = date ?? DateTime.now();

      final newAttendance = Attendance(
        id: newAttendanceDoc.id,
        userId: studentId,
        institutionId: institutionId,
        classId: institutionClass.id,
        isPresent: isPresent,
        markedByUserId: markedByUserId.id,
        createdAt: attendanceDate,
        updatedAt: attendanceDate,
      );

      await newAttendanceDoc.set(newAttendance);

      // Create activity record
      final newActivityDoc = DbService.activitiesCollRef().doc();

      final newActivity = Activity(
        id: newActivityDoc.id,
        userId: markedByUserId.id,
        userName: markedByUserId.name,
        activityType: ActivityType.attendance,
        title: 'Attendance Marked',
        description:
            'Marked attendance for student as ${isPresent ? 'present' : 'absent'}',
        createdAt: attendanceDate,
        data: AttendanceActivity(
          className: institutionClass.name,
          classId: institutionClass.id,
          teacherName: markedByUserId.name,
          teacherId: markedByUserId.id,
          date: attendanceDate,
          isPresent: isPresent,
        ),
        forUserId: studentId,
      );

      await newActivityDoc.set(newActivity);
    } catch (e) {
      debugPrint('Error in updateStudentAttendance: $e');
      rethrow;
    }
  }

  static Future<void> updateAttendanceRecord({
    required String attendanceId,
    required bool isPresent,
  }) async {
    final attendanceDoc = DbService.attendancesCollRef().doc(attendanceId);

    await attendanceDoc.update({
      'isPresent': isPresent,
      'updatedAt': Timestamp.now(),
    });
  }
}
