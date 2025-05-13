import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_state.dart';
import 'package:potential_plus/services/db_service.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';

class AttendanceController extends StateNotifier<AttendanceState> {
  final Ref ref;

  AttendanceController(this.ref) : super(AttendanceState.initial()) {
    loadAllAttendance();
  }

  Future<void> loadAllAttendance() async {
    state = state.copyWith(isLoading: true);
    final user = ref.read(authProvider).value;
    if (user == null) return;

    try {
      final query = DbService.attendancesCollRef()
          .where('userId', isEqualTo: user.id)
          .where('institutionId', isEqualTo: user.institutionId)
          .where('dateTime', isGreaterThanOrEqualTo: state.firstDay)
          .where('dateTime', isLessThanOrEqualTo: state.lastDay);

      final attendances = await query.get();
      final events = <DateTime, List<Attendance>>{};

      for (var doc in attendances.docs) {
        final attendance = doc.data();
        final date = DateTime(
          attendance.dateTime.year,
          attendance.dateTime.month,
          attendance.dateTime.day,
        );
        events[date] = [...(events[date] ?? []), attendance];
      }

      state = state.copyWith(
        attendanceEvents: events,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectDay(DateTime day) {
    state = state.copyWith(
      selectedDay: day,
      focusedDay: day,
    );
  }

  void changeFocusedDay(DateTime day) {
    state = state.copyWith(focusedDay: day);
  }

  List<Attendance> getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return state.attendanceEvents[normalizedDay] ?? [];
  }

  bool isDayPresent(DateTime day) {
    final events = getEventsForDay(day);
    return events.any((event) => event.isPresent);
  }
}

final attendanceControllerProvider =
    StateNotifierProvider<AttendanceController, AttendanceState>((ref) {
  return AttendanceController(ref);
});
