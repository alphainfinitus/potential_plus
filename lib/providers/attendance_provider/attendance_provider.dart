import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/controllers/attendance_controller.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/services/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_state_notifier.dart';

// Selected class provider
final selectedClassProvider = StateProvider<InstitutionClass?>((ref) => null);

// Selected date provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Selected lecture provider
final selectedLectureProvider = StateProvider<TimetableEntry?>((ref) => null);

// Attendance state provider
final attendanceStateProvider =
    StateNotifierProvider<AttendanceStateNotifier, Map<String, bool>>((ref) {
  return AttendanceStateNotifier();
});

// Attendance watcher provider
final attendanceWatcherProvider = Provider((ref) {
  final selectedClass = ref.watch(selectedClassProvider);
  final selectedLecture = ref.watch(selectedLectureProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final attendanceState = ref.watch(attendanceStateProvider.notifier);

  if (selectedClass != null && selectedLecture != null) {
    attendanceState.fetchAndUpdateAttendance(
      classId: selectedClass.id,
      timeTableEntryId: selectedLecture.id,
      date: selectedDate,
    );
  }
});

// Class timetable provider
final classTimetableProvider =
    FutureProvider.family<TimeTable?, String>((ref, classId) async {
  return await DbService.getClassTimetable(classId);
});

// Class students provider
final classStudentsProvider =
    FutureProvider.family<List<AppUser>, String>((ref, classId) async {
  final querySnapshot = await DbService.classStudentsQueryRef(classId).get();
  return querySnapshot.docs.map((doc) => doc.data()).toList();
});

// Attendance parameters class
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

// Lecture attendance provider
final lectureAttendanceProvider =
    FutureProvider.family<Map<String, bool>, AttendanceParams>(
        (ref, params) async {
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
});

// Attendance controller provider
final attendanceControllerProvider =
    Provider.family<AttendanceController?, AttendanceParams>((ref, params) {
  final currentUser = ref.watch(authProvider).value;
  if (currentUser == null) return null;

  final timetableAsync = ref.watch(classTimetableProvider(params.classId));
  return timetableAsync.when(
    data: (timetable) {
      if (timetable == null) return null;

      final selectedEntry = timetable.entries.firstWhere(
        (entry) => entry.id == params.timeTableEntryId,
        orElse: () => TimetableEntry(
          id: '',
          day: 0,
          subject: '',
          from: null,
          to: null,
          teacherId: '',
          entryNumber: 0,
        ),
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
});
