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
    required String markedByUserId,
    required String classId,
  }) async {
    try {
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

      await newAttendanceDoc.set(newAttendance);

      // Create activity record
      final newActivityDoc = DbService.activitiesCollRef().doc();

      final newActivity = Activity(
        id: newActivityDoc.id,
        teacherId: markedByUserId,
        type: 'attendance',
        title: 'Attendance Marked',
        description: 'Marked attendance for student $studentId',
        timestamp: DateTime.now(),
      );

      await newActivityDoc.set(newActivity);
    } catch (e) {
      print('Error in updateStudentAttendance: $e');
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
