import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/screens/attendance/controllers/attendance_controller.dart';
import 'package:potential_plus/services/db_service.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';

part 'attendance_provider.g.dart';

@riverpod
class SelectedClass extends _$SelectedClass {
  @override
  InstitutionClass? build() => null;
  void set(InstitutionClass? value) => state = value;
}

@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();
  void set(DateTime value) => state = value;
}

@riverpod
class SelectedLecture extends _$SelectedLecture {
  @override
  TimetableEntry? build() => null;
  void set(TimetableEntry? value) => state = value;
}

@riverpod
class AttendanceState extends _$AttendanceState {
  @override
  Map<String, bool> build() => {};

  Future<void> fetchAndUpdateAttendance({
    required String classId,
    required String timeTableEntryId,
    required DateTime date,
  }) async {
    try {
      final currentUser = ref.read(authProvider).value;
      if (currentUser == null) return;

      final attendanceMap = await DbService.getLectureAttendance(
        classId: classId,
        timeTableEntryId: timeTableEntryId,
        date: date,
      );

      // Only set state if attendance exists in Firebase
      if (attendanceMap.isNotEmpty) {
        state = attendanceMap;
      } else {
        state = {};
      }
    } catch (e) {
      state = {};
    }
  }

  void updateAttendance(String studentId, bool isPresent) {
    state = {...state, studentId: isPresent};
  }

  Future<void> submitAttendance() async {
    try {
      final currentUser = ref.read(authProvider).value;
      if (currentUser == null) return;

      final selectedClass = ref.read(selectedClassProvider);
      final selectedLecture = ref.read(selectedLectureProvider);
      final selectedDate = ref.read(selectedDateProvider);

      if (selectedClass == null || selectedLecture == null) return;

      final timetable =
          await ref.read(classTimetableProvider(selectedClass.id).future);
      if (timetable == null) return;

      final attendanceData = state.entries
          .map((entry) => {
                'userId': entry.key,
                'isPresent': entry.value,
                'markedByUserId': currentUser.id,
                'subject': selectedLecture.subject,
              })
          .toList();

      await DbService.markAttendance(
        institutionId: currentUser.institutionId,
        classId: selectedClass.id,
        timeTableId: timetable.id,
        timeTableEntryId: selectedLecture.id,
        attendanceData: attendanceData,
        date: selectedDate,
      );
    } catch (e) {
      // Revert state on error
      state = {...state};
      rethrow; // Rethrow to handle in UI
    }
  }
}

@riverpod
void attendanceWatcher(Ref ref) {
  final selectedClass = ref.watch(selectedClassProvider);
  final selectedLecture = ref.watch(selectedLectureProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final notifier = ref.watch(attendanceStateProvider.notifier);

  if (selectedClass != null && selectedLecture != null) {
    Future.microtask(() async {
      if (ref.read(attendanceStateProvider).isEmpty) {
        await notifier.fetchAndUpdateAttendance(
          classId: selectedClass.id,
          timeTableEntryId: selectedLecture.id,
          date: selectedDate,
        );
      }
    });
  }
}

@riverpod
Future<TimeTable?> classTimetable(Ref ref, String classId) async {
  return await DbService.getClassTimetable(classId);
}

@riverpod
Future<List<AppUser>> classStudents(Ref ref, String classId) async {
  final querySnapshot = await DbService.classStudentsQueryRef(classId).get();
  return querySnapshot.docs.map((doc) => doc.data()).toList();
}

class AttendanceParams {
  final String classId;
  final String timeTableEntryId;
  final DateTime date;

  const AttendanceParams({
    required this.classId,
    required this.timeTableEntryId,
    required this.date,
  });
}

@riverpod
Future<Map<String, bool>> lectureAttendance(
    Ref ref, AttendanceParams params) async {
  return await DbService.getLectureAttendance(
    classId: params.classId,
    timeTableEntryId: params.timeTableEntryId,
    date: params.date,
  );
}

@riverpod
AttendanceController? attendanceController(Ref ref, AttendanceParams params) {
  final currentUser = ref.watch(authProvider).value;
  if (currentUser == null) return null;

  final timetableAsync = ref.watch(classTimetableProvider(params.classId));
  return timetableAsync.when(
    data: (timetable) {
      if (timetable == null) return null;

      final selectedEntry = timetable.entries.firstWhere(
        (entry) => entry.id == params.timeTableEntryId,
      );

      if (selectedEntry.id.isEmpty || currentUser.id.isEmpty) return null;

      return AttendanceController(
        institutionId: currentUser.institutionId,
        classId: params.classId,
        timeTableId: timetable.id,
        timeTableEntryId: selectedEntry.id,
        date: params.date,
        markedByUserId: currentUser.id,
        subject: selectedEntry.subject,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
}
