import 'package:potential_plus/models/attendance.dart';

class AttendanceState {
  final Map<DateTime, List<Attendance>> attendanceEvents;
  final bool isLoading;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final DateTime firstDay;
  final DateTime lastDay;

  const AttendanceState({
    required this.attendanceEvents,
    required this.isLoading,
    required this.focusedDay,
    this.selectedDay,
    required this.firstDay,
    required this.lastDay,
  });

  AttendanceState copyWith({
    Map<DateTime, List<Attendance>>? attendanceEvents,
    bool? isLoading,
    DateTime? focusedDay,
    DateTime? selectedDay,
    DateTime? firstDay,
    DateTime? lastDay,
  }) {
    return AttendanceState(
      attendanceEvents: attendanceEvents ?? this.attendanceEvents,
      isLoading: isLoading ?? this.isLoading,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      firstDay: firstDay ?? this.firstDay,
      lastDay: lastDay ?? this.lastDay,
    );
  }

  factory AttendanceState.initial() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final firstDay = DateTime(now.year, now.month - 10, 1);

    return AttendanceState(
      attendanceEvents: {},
      isLoading: true,
      focusedDay: now,
      selectedDay: null,
      firstDay: firstDay,
      lastDay: lastDay,
    );
  }
}
