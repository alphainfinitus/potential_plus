import 'package:potential_plus/models/attendance/attendance.dart';
import 'package:potential_plus/models/institution/institution.dart';
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

    await DbService.updateClassPeriodDetails(
      institution.id,
      institutionClass.id,
      newTimetable
    );
  }

  static Future<List<Attendance>> fetchClassAttendanceByDate(String institutionId, String institutionClassId, DateTime date) async {
    return await DbService.fetchClassAttendanceByDate(institutionId: institutionId, institutionClassId: institutionClassId, date: date);
  }
}