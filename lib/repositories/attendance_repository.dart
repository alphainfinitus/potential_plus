import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/services/db_service.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

class AttendanceRepository {
  Future<List<Attendance>> getAttendance() async {
    try {
      final snapshot = await DbService.attendancesCollRef().get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to fetch attendance records: $e');
    }
  }

  Future<Attendance> updateAttendance({
    required String attendanceId,
    required bool isPresent,
  }) async {
    try {
      final attendanceDoc = DbService.attendancesCollRef().doc(attendanceId);

      // Update the document
      await attendanceDoc.update({
        'isPresent': isPresent,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Fetch the updated document
      final doc = await attendanceDoc.get();

      if (!doc.exists) {
        throw Exception('Attendance record not found');
      }

      // Return the updated attendance
      return doc.data()!;
    } catch (e) {
      throw Exception('Failed to update attendance: $e');
    }
  }
}
