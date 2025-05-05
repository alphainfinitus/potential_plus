import 'dart:developer';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/services/db_service.dart';

class AttendanceController {
  final String institutionId;
  final String classId;
  final String timeTableId;
  final String timeTableEntryId;
  final DateTime date;
  final String markedByUserId;
  final String subject;

  const AttendanceController({
    required this.institutionId,
    required this.classId,
    required this.timeTableId,
    required this.timeTableEntryId,
    required this.date,
    required this.markedByUserId,
    required this.subject,
  });

  static Future<Map<String, bool>> fetchAttendance({
    required String classId,
    required String timeTableEntryId,
    required DateTime date,
  }) async {
    try {
      // Validate inputs
      if (classId.isEmpty || timeTableEntryId.isEmpty) {
        log("Invalid inputs for attendance fetch");
        return {};
      }

      log("Fetching attendance for class: $classId, lecture: $timeTableEntryId, date: $date");
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day + 1);
      final querySnapshot = await DbService.attendancesCollRef()
          .where('classId', isEqualTo: classId)
          .where('metaData.timeTableEntryId', isEqualTo: timeTableEntryId)
          .where('forDate', isGreaterThanOrEqualTo: startOfDay)
          .where('forDate', isLessThan: endOfDay)
          .get();

      final Map<String, bool> attendanceMap = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        attendanceMap[data.userId] = data.isPresent;
      }

      log("Fetched attendance: $attendanceMap");
      return attendanceMap;
    } catch (e) {
      log("Error fetching attendance: $e");
      return {};
    }
  }

  Future<void> markAttendance(
      List<AppUser> students, Map<String, bool> attendance) async {
    try {
      // Validate inputs
      if (classId.isEmpty || timeTableEntryId.isEmpty || students.isEmpty) {
        log("Invalid inputs for marking attendance");
        return;
      }

      log("Marking attendance for class: $classId, lecture: $timeTableEntryId, date: $date");
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day + 1);

      // Delete existing attendance records for this lecture and date
      final existingQuery = await DbService.attendancesCollRef()
          .where('classId', isEqualTo: classId)
          .where('metaData.timeTableEntryId', isEqualTo: timeTableEntryId)
          .where('forDate', isGreaterThanOrEqualTo: startOfDay)
          .where('forDate', isLessThan: endOfDay)
          .get();

      for (var doc in existingQuery.docs) {
        await doc.reference.delete();
      }

      // Create new attendance records
      final batch = DbService.db.batch();
      for (var student in students) {
        final isPresent = attendance[student.id] ?? false;
        final attendanceRef = DbService.attendancesCollRef().doc();
        batch.set(attendanceRef, {
          'userId': student.id,
          'classId': classId,
          'metaData': {
            'timeTableId': timeTableId,
            'timeTableEntryId': timeTableEntryId,
            'subject': subject,
            'institutionId': institutionId,
          },
          'isPresent': isPresent,
          'forDate': date,
          'createdAt': DateTime.now(),
          'createdBy': markedByUserId,
        });
      }
      await batch.commit();

      log("Successfully marked attendance");
    } catch (e) {
      log("Error marking attendance: $e");
      rethrow;
    }
  }
}
