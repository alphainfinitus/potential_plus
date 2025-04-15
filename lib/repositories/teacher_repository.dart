import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/models/activity.dart';
import 'package:potential_plus/models/attendance.dart';
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
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .where('date', isGreaterThanOrEqualTo: date)
          .where('date', isLessThan: DateTime(date.year, date.month + 1, 1))
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
    required String markedByUserId,
    required String classId,
  }) async {
    // TODO: use transactions to ensure atomicity
    // TODO: control flow is too messy, refactor

    final batch = DbService.db.batch();

    // 1. check if attendance already exists for today
    final todayAttendanceSnapshot = (await DbService.attendanceForDateQueryRef(
                userId: studentId,
                institutionId: institutionId,
                date: DateTime.now())
            .limit(1)
            .get())
        .docs
        .firstOrNull;

    // 2. if it exists, update the attendance and the corresponding activity
    if (todayAttendanceSnapshot != null) {
      batch.update(todayAttendanceSnapshot.reference, {
        'isPresent': isPresent,
        'markedByUserId': markedByUserId,
        'updatedAt': Timestamp.now(),
      });

      // 2.1. update the corresponding activity
      final activitySnapshot = await DbService.activityByActivityRefIdQueryRef(
              todayAttendanceSnapshot.id)
          .limit(1)
          .get();
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
          teacherId: markedByUserId,
          type: 'attendance',
          title: 'Attendance Marked',
          description: 'Marked attendance for student $studentId',
          timestamp: DateTime.now(),
        );

        batch.set(newActivityDoc, newActivity.toMap());
      }
    }
    // 3. if it doesn't exist, create it
    else {
      final newAttendanceDoc = DbService.attendancesCollRef().doc();

      final newAttendance = Attendance(
        id: newAttendanceDoc.id,
        userId: studentId,
        institutionId: institutionId,
        classId: classId,
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
        teacherId: markedByUserId,
        type: 'attendance',
        title: 'Attendance Marked',
        description: 'Marked attendance for student $studentId',
        timestamp: DateTime.now(),
      );

      batch.set(newActivityDoc, newActivity.toMap());
    }

    await batch.commit();
  }
}
