import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/services/db_service.dart';

class AttendanceController {
  final String institutionId;
  final String classId;
  final String timeTableId;
  final String timeTableEntryId;
  final DateTime date;
  final String subject;
  final String markedByUserId;

  AttendanceController({
    required this.institutionId,
    required this.classId,
    required this.timeTableId,
    required this.timeTableEntryId,
    required this.date,
    required this.subject,
    required this.markedByUserId,
  });

  Future<Map<String, bool>> getAttendance() async {
    return await DbService.getLectureAttendance(
      classId: classId,
      timeTableEntryId: timeTableEntryId,
      date: date,
    );
  }

  Future<void> markAttendance(
      List<AppUser> students, Map<String, bool> attendance) async {
    final attendanceData = students
        .map((student) => {
              'userId': student.id,
              'isPresent': attendance[student.id] ?? false,
              'markedByUserId': markedByUserId,
              'subject': subject,
            })
        .toList();

    await DbService.markAttendance(
      institutionId: institutionId,
      date: date,
      classId: classId,
      timeTableId: timeTableId,
      timeTableEntryId: timeTableEntryId,
      attendanceData: attendanceData,
    );
  }
}
