import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/constants/activity_type.dart';
import 'package:potential_plus/models/activity/activity.dart';
import 'package:potential_plus/models/attendance/attendance.dart';
import 'package:potential_plus/services/db_service.dart';

class TeacherRepository {
  static Future updateStudentAttendance({
    required String studentId,
    required bool isPresent,
    required String institutionId,
    required String markedByUserId,
  }) async {
    // TODO: use transactions to ensure atomicity
    // TODO: control flow is too messy, refactor

    final batch = DbService.db.batch();

    // 1. check if attendance already exists for today
    final todayAttendanceSnapshot = (await DbService.attendanceForDateQueryRef(userId: studentId, institutionId: institutionId, date: DateTime.now()).limit(1).get()).docs.firstOrNull;

    // 2. if it exists, update the attendance and the corresponding activity
    if (todayAttendanceSnapshot != null) {
      batch.update(todayAttendanceSnapshot.reference, {
        'isPresent': isPresent,
        'markedByUserId': markedByUserId,
        'updatedAt': Timestamp.now(),
      });

      // 2.1. update the corresponding activity
      final activitySnapshot = await DbService.activityByActivityRefIdQueryRef(todayAttendanceSnapshot.id).limit(1).get();
      final activity = activitySnapshot.docs.firstOrNull;

      if (activity != null) {
        batch.update(activity.reference, {
          'updatedAt': Timestamp.now(),
        });
      }
      // 2.2. create an activity for the attendance
      else {
        final newActivityDoc = DbService.activitiesCollRef().doc();

        final newActivity = Activity(
          id: newActivityDoc.id,
          userId: studentId,
          activityType: ActivityType.attendance,
          activityRefId: todayAttendanceSnapshot.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        batch.set(newActivityDoc, newActivity);
      }
    }
    // 3. if it doesn't exist, create it
    else {
      final newAttendanceDoc = DbService.attendancesCollRef().doc();

      final newAttendance = Attendance(
        id: newAttendanceDoc.id,
        userId: studentId,
        institutionId: institutionId,
        isPresent: isPresent,
        markedByUserId: markedByUserId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      batch.set(newAttendanceDoc, newAttendance);

      // 4. create an activity for the attendance
      final newActivityDoc = DbService.activitiesCollRef().doc();

      final newActivity = Activity(
        id: newActivityDoc.id,
        userId: studentId,
        activityType: ActivityType.attendance,
        activityRefId: newAttendanceDoc.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      batch.set(newActivityDoc, newActivity);
    }

    await batch.commit();
  }
}