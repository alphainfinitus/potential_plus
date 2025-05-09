import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/controllers/attendance_controller.dart';
import 'package:potential_plus/services/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      final attendance = await AttendanceController.fetchAttendance(
        classId: classId,
        timeTableEntryId: timeTableEntryId,
        date: date,
      );
      state = attendance;
    } catch (_) {
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

@riverpod
void attendanceWatcher(Ref ref) {
  final selectedClass = ref.watch(selectedClassProvider);
  final selectedLecture = ref.watch(selectedLectureProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final notifier = ref.watch(attendanceStateProvider.notifier);

  if (selectedClass != null && selectedLecture != null) {
    notifier.fetchAndUpdateAttendance(
      classId: selectedClass.id,
      timeTableEntryId: selectedLecture.id,
      date: selectedDate,
    );
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
  final currentUser = ref.watch(authProvider).value;
  if (currentUser == null) return {};

  final attendanceRef = FirebaseFirestore.instance
      .collection('institutions')
      .doc(currentUser.institutionId)
      .collection('classes')
      .doc(params.classId)
      .collection('attendance')
      .doc(
          '${params.timeTableEntryId}_${params.date.toIso8601String().split('T')[0]}');

  final attendanceDoc = await attendanceRef.get();
  if (!attendanceDoc.exists) return {};

  final data = attendanceDoc.data() as Map<String, dynamic>;
  final attendance = data['attendance'] as Map<String, dynamic>;
  return attendance.map((key, value) => MapEntry(key, value as bool));
}

@riverpod
AttendanceController? attendanceController(
    Ref ref, AttendanceParams params) {
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
