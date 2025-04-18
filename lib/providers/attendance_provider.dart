import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/repositories/attendance_repository.dart';

final attendanceNotifierProvider =
    StateNotifierProvider<AttendanceNotifier, AsyncValue<List<Attendance>>>(
  (ref) => AttendanceNotifier(ref.watch(attendanceRepositoryProvider)),
);

class AttendanceNotifier extends StateNotifier<AsyncValue<List<Attendance>>> {
  final AttendanceRepository _repository;

  AttendanceNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    try {
      final attendance = await _repository.getAttendance();
      state = AsyncValue.data(attendance);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateAttendance({
    required String attendanceId,
    required bool isPresent,
  }) async {
    try {
      // Update the attendance and get the updated record
      final updatedAttendance = await _repository.updateAttendance(
        attendanceId: attendanceId,
        isPresent: isPresent,
      );

      // Update the state with the new attendance list
      state.whenData((attendanceList) {
        final updatedList = attendanceList.map((attendance) {
          if (attendance.id == attendanceId) {
            return updatedAttendance;
          }
          return attendance;
        }).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (error, stackTrace) {
      log(
        '$attendanceId $error',
      );
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
