import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/controllers/attendance_controller.dart';

class AttendanceStateNotifier extends StateNotifier<Map<String, bool>> {
  AttendanceStateNotifier() : super({});

  Future<void> fetchAndUpdateAttendance({
    required String classId,
    required String timeTableEntryId,
    required DateTime date,
  }) async {
    try {
      final attendance = await AttendanceController.fetchAttendance(
        classId: classId,
        timeTableEntryId: timeTableEntryId,
        date: date,
      );
      state = attendance;
    } catch (e) {
      log("Error in fetchAndUpdateAttendance: $e");
      state = {};
    }
  }

  void updateAttendance(String studentId, bool isPresent) {
    state = {...state, studentId: isPresent};
  }

  void clearAttendance() {
    state = {};
  }
}
