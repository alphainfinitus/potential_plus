import 'package:potential_plus/services/db_service.dart';

class TeacherRepository {
  static Future updateStudentAttendance({
    required String studentId,
    required bool isPresent,
    required String institutionId,
    required String markedByUserId,
  }) async {
    await DbService.updateStudentAttendance(
      studentId: studentId,
      isPresent: isPresent,
      institutionId: institutionId,
      markedByUserId: markedByUserId,
    );
  }
}