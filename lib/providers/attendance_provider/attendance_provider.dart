import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/services/db_service.dart';
import 'package:potential_plus/controllers/attendance_controller.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';

final attendanceStateProvider =
    StateNotifierProvider<AttendanceNotifier, Map<String, bool>>((ref) {
  return AttendanceNotifier();
});

class AttendanceNotifier extends StateNotifier<Map<String, bool>> {
  AttendanceNotifier() : super({});

  void setAttendance(Map<String, bool> attendance) {
    state = attendance;
  }

  void toggleAttendance(String studentId, bool isPresent) {
    state = {...state, studentId: isPresent};
  }

  void setAllAttendance(bool isPresent) {
    state = Map.fromEntries(state.keys.map((key) => MapEntry(key, isPresent)));
  }
}

final attendanceControllerProvider =
    Provider.family<AttendanceController?, (String, String, DateTime)>(
        (ref, params) {
  final (classId, timeTableEntryId, date) = params;
  final currentUser = ref.watch(authProvider).value;

  final timetableAsync = ref.watch(classTimetableProvider(classId));
  final selectedEntry = timetableAsync.when(
    data: (timetable) => timetable?.entries.firstWhere(
      (entry) => entry.id == timeTableEntryId,
      orElse: () => TimetableEntry(
        id: '',
        subject: '',
        teacherId: '',
        day: 0,
        entryNumber: 0,
      ),
    ),
    loading: () => null,
    error: (_, __) => null,
  );

  if (selectedEntry == null ||
      currentUser == null ||
      selectedEntry.id.isEmpty) {
    return null;
  }

  return AttendanceController(
    institutionId: currentUser.institutionId,
    classId: classId,
    timeTableId: timetableAsync.value?.id ?? '',
    timeTableEntryId: timeTableEntryId,
    date: date,
    subject: selectedEntry.subject,
    markedByUserId: currentUser.id,
  );
});

final attendanceDataProvider =
    FutureProvider.family<Map<String, bool>, (String, String, DateTime)>(
        (ref, params) async {
  final (classId, timeTableEntryId, date) = params;

  final controller = ref
      .watch(attendanceControllerProvider((classId, timeTableEntryId, date)));
  if (controller == null) return {};

  return await controller.getAttendance();
});

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
    final startOfDay =
        DateTime(params.date.year, params.date.month, params.date.day);
    final endOfDay =
        DateTime(params.date.year, params.date.month, params.date.day + 1);
    final querySnapshot = await DbService.attendancesCollRef()
        .where('classId', isEqualTo: params.classId)
        .where('metaData.timeTableEntryId', isEqualTo: params.timeTableEntryId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .where('createdAt', isLessThan: endOfDay)
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
});
