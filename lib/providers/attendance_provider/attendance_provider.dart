import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/services/db_service.dart';
import 'package:cuid2/cuid2.dart';

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AsyncValue<void>>((ref) {
  return AttendanceNotifier();
});

class AttendanceNotifier extends StateNotifier<AsyncValue<void>> {
  AttendanceNotifier() : super(const AsyncValue.data(null));

  Future<void> markAttendance({
    required String institutionId,
    required String classId,
    required String timeTableId,
    required String timeTableEntryId,
    required List<Map<String, dynamic>> attendanceData,
  }) async {
    try {
      state = const AsyncValue.loading();

      // First, get existing attendance records for this lecture and date
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day + 1);

      final existingAttendanceQuery = await DbService.attendancesCollRef()
          .where('classId', isEqualTo: classId)
          .where('metaData.timeTableEntryId', isEqualTo: timeTableEntryId)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('createdAt', isLessThan: endOfDay)
          .get();

      // Create a map of existing attendance records by userId
      final Map<String, String> existingAttendanceIds = {};
      for (var doc in existingAttendanceQuery.docs) {
        final data = doc.data();
        existingAttendanceIds[data.userId] = doc.id;
      }

      // Process each attendance record
      for (var data in attendanceData) {
        final userId = data['userId'] as String;
        final existingId = existingAttendanceIds[userId];

        final attendance = Attendance(
          id: existingId ??
              cuid(), // Use existing ID if available, otherwise create new
          userId: userId,
          isPresent: data['isPresent'],
          institutionId: institutionId,
          classId: classId,
          createdAt: existingId != null
              ? DateTime.now()
              : DateTime.now(), // Keep original creation date if updating
          updatedAt: DateTime.now(),
          markedByUserId: data['markedByUserId'],
          metaData: MetaData(
            subject: data['subject'],
            timeTableId: timeTableId,
            timeTableEntryId: timeTableEntryId,
          ),
        );

        final docRef = DbService.attendancesCollRef().doc(attendance.id);
        await docRef.set(attendance);
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      log("error: $e");
      state = AsyncValue.error(e, stack);
    }
  }
}

// Providers for UI state
final selectedClassProvider = StateProvider<InstitutionClass?>((ref) => null);
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedLectureProvider = StateProvider<TimetableEntry?>((ref) => null);
final studentAttendanceProvider = StateProvider<Map<String, bool>>((ref) => {});

// Provider for fetching students in a class
final classStudentsProvider =
    FutureProvider.family<List<AppUser>, String>((ref, classId) async {
  final querySnapshot = await DbService.classStudentsQueryRef(classId).get();
  return querySnapshot.docs.map((doc) => doc.data()).toList();
});

// Provider for fetching timetable
final classTimetableProvider =
    FutureProvider.family<TimeTable?, String>((ref, classId) async {
  return await DbService.getClassTimetable(classId);
});

// Provider to track attendance parameters
final attendanceParamsProvider =
    StateProvider<({String classId, String timeTableEntryId, DateTime date})?>(
        (ref) => null);

// Provider for fetching existing attendance
final lectureAttendanceProvider = FutureProvider.family<
    Map<String, bool>,
    ({
      String classId,
      String timeTableEntryId,
      DateTime date
    })>((ref, params) async {
  try {
    final querySnapshot = await DbService.attendancesCollRef()
        .where('classId', isEqualTo: params.classId)
        .where('metaData.timeTableEntryId', isEqualTo: params.timeTableEntryId)
        .where('createdAt',
            isGreaterThanOrEqualTo:
                DateTime(params.date.year, params.date.month, params.date.day))
        .where('createdAt',
            isLessThan: DateTime(
                params.date.year, params.date.month, params.date.day + 1))
        .get();

    final Map<String, bool> attendanceMap = {};
    for (var doc in querySnapshot.docs) {
      final attendance = doc.data();
      attendanceMap[attendance.userId] = attendance.isPresent;
    }
    return attendanceMap;
  } catch (e) {
    log("Error fetching attendance: $e");
    return {};
  }
});
