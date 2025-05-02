import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/services/db_service.dart';

class InstitutionClassRepository {
  static Future updateClassPeriodDetails(
    Institution institution,
    InstitutionClass institutionClass,
    int editedDayOfWeekIndex,
    int editedPeriodIndex,
  ) async {
    
  }

  static Future<List<Attendance>> fetchClassAttendanceByDate({
		required String institutionId,
		required String institutionClassId,
		required DateTime date,
	}) async {
		//1. get all students in the class
		final studentsSnapshot = await DbService.classStudentsQueryRef(institutionClassId).get();
		final students = studentsSnapshot.docs.map((doc) => doc.data()).toList();

		final studentIds = students.map((student) => student.id).toList();

		final startOfDay = DateTime(date.year, date.month, date.day);
    final startOfTomorrow = DateTime(date.year, date.month, date.day + 1);

		final attendancesSnapshot = await DbService.attendancesCollRef()
      .where('userId', whereIn: studentIds)
      .where('forDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('forDate', isLessThan: Timestamp.fromDate(startOfTomorrow))
      .get();

		//3. return the attendances
		return attendancesSnapshot.docs.map((doc) => doc.data()).toList();
	}

  static Future<Map<String, AppUser>> fetchClassStudents({
    required String classId,
  }) async {
    final studentsSnapshot = await DbService.classStudentsQueryRef(classId).get();

    return studentsSnapshot.docs.fold<Map<String, AppUser>>(
      {},
      (acc, doc) => acc..[doc.id] = doc.data(),
    );
  }
}