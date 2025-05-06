import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/services/db_service.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart';
import 'package:potential_plus/models/app_user.dart';

class AttendanceController {
  final String institutionId;
  final String classId;
  final String timeTableId;
  final String timeTableEntryId;
  final DateTime date;
  final String markedByUserId;

  const AttendanceController({
    required this.institutionId,
    required this.classId,
    required this.timeTableId,
    required this.timeTableEntryId,
    required this.date,
    required this.markedByUserId,
  });

  static Future<Map<String, bool>> fetchAttendance({
    required String classId,
    required String timeTableEntryId,
    required DateTime date,
  }) async {
    try {
      // Validate inputs
      if (classId.isEmpty || timeTableEntryId.isEmpty) {
        return {};
      }

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

      return attendanceMap;
    } catch (e) {
      return {};
    }
  }

  Future<void> markAttendance(
      List<AppUser> students, Map<String, bool> attendance) async {
    try {
      // Validate inputs
      if (classId.isEmpty || timeTableEntryId.isEmpty || students.isEmpty) {
        return;
      }

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
            'institutionId': institutionId,
          },
          'isPresent': isPresent,
          'forDate': date,
          'createdAt': DateTime.now(),
          'createdBy': markedByUserId,
        });
      }
      await batch.commit();

    } catch (e) {
      rethrow;
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
