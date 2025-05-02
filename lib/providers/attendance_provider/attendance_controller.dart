import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/services/db_service.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart';

class AttendanceController {
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
      log("Error fetching attendanceeee: $e");
      return {};
    }
  }
}

// Provider to manage attendance state
final attendanceStateProvider =
    StateNotifierProvider<AttendanceStateNotifier, Map<String, bool>>((ref) {
  return AttendanceStateNotifier();
});

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
}

// Provider to watch attendance parameters and trigger fetches
final attendanceWatcherProvider = Provider<void>((ref) {
  final selectedClass = ref.watch(selectedClassProvider);
  final selectedLecture = ref.watch(selectedLectureProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final attendanceState = ref.watch(attendanceStateProvider.notifier);

  if (selectedClass != null && selectedLecture != null) {
    // Fetch attendance whenever parameters change
    attendanceState.fetchAndUpdateAttendance(
      classId: selectedClass.id,
      timeTableEntryId: selectedLecture.id,
      date: selectedDate,
    );
  }
});
