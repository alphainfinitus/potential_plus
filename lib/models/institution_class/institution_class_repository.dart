import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/models/attendance/attendance.dart';
import 'package:potential_plus/models/institution/institution.dart';
import 'package:potential_plus/models/institution/institution_repository.dart';
import 'package:potential_plus/models/institution_class/institution_class.dart';
import 'package:potential_plus/services/db_service.dart';

class InstitutionClassRepository {
  static Future updateClassPeriodDetails(
    Institution institution,
    InstitutionClass institutionClass,
    int editedDayOfWeekIndex,
    int editedPeriodIndex,
    TimetableEntry editedTimeTableEntry,
  ) async {
    Map<String, List<TimetableEntry>> newTimetable = {};

    // loop through each day of the week, and for each period, populate old period details and update the new period details
    for (int dayOfWeekIndex = 0; dayOfWeekIndex < 7; dayOfWeekIndex++) {
      newTimetable[dayOfWeekIndex.toString()] = [];

      for (int periodIndex = 0; periodIndex <= institution.periodCount - 1; periodIndex++) {
        if (dayOfWeekIndex == editedDayOfWeekIndex && periodIndex == editedPeriodIndex) {
          newTimetable[dayOfWeekIndex.toString()]!.add(editedTimeTableEntry);
        } else {
          newTimetable[dayOfWeekIndex.toString()]!.add(
            (institutionClass.timeTable[dayOfWeekIndex.toString()] != null &&
              institutionClass.timeTable[dayOfWeekIndex.toString()]!.length > periodIndex) ?
                institutionClass.timeTable[dayOfWeekIndex.toString()]![periodIndex] :
                  const TimetableEntry(subject: '', teacherId: '')
          );
        }
      }
    }

    await InstitutionRepository.updateClassPeriodDetails(
      institutionId: institution.id,
      institutionClassId: institutionClass.id,
      newTimeTable: newTimetable,
    );
  }

  static Future<List<Attendance>> fetchClassAttendanceByDate({
		required String institutionId,
		required String institutionClassId,
		required DateTime date,
	}) async {
		//1. get all students in the class
		final studentsSnapshot = await DbService.institutionStudentsQueryRef(institutionId).get();
		final students = studentsSnapshot.docs.map((doc) => doc.data()).toList();

		final studentIds = students.map((student) => student.id).toList();

		final startOfDay = DateTime(date.year, date.month, date.day);
    final startOfTomorrow = DateTime(date.year, date.month, date.day + 1);

		final attendancesSnapshot = await DbService.attendancesCollRef()
      .where('institutionId', isEqualTo: institutionId)
      .where('userId', whereIn: studentIds)
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('createdAt', isLessThan: Timestamp.fromDate(startOfTomorrow))
      .get();

		//3. return the attendances
		return attendancesSnapshot.docs.map((doc) => doc.data()).toList();
	}
}