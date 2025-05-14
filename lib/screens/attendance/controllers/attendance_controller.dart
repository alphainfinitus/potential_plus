import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/services/db_service.dart';

class AttendanceController {
  final String institutionId;
  final String classId;
  final String timeTableId;
  final String timeTableEntryId;
  final DateTime date;
  final String markedByUserId;
  final String subject;

  AttendanceController({
    required this.institutionId,
    required this.classId,
    required this.timeTableId,
    required this.timeTableEntryId,
    required this.date,
    required this.markedByUserId,
    required this.subject,
  });

  Future<void> markAttendance(
    List<AppUser> students,
    Map<String, bool> attendanceState,
  ) async {
    final attendanceData = attendanceState.entries
        .map((entry) => {
              'userId': entry.key,
              'isPresent': entry.value,
              'markedByUserId': markedByUserId,
              'subject': subject,
            })
        .toList();

    await DbService.markAttendance(
      institutionId: institutionId,
      classId: classId,
      timeTableId: timeTableId,
      timeTableEntryId: timeTableEntryId,
      attendanceData: attendanceData,
      date: date,
    );
  }
}
