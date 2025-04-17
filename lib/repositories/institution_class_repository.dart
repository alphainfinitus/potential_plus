import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/repositories/institution_repository.dart';
import 'package:potential_plus/models/institution_class.dart';
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

      for (int periodIndex = 0;
          periodIndex <= institution.periodCount - 1;
          periodIndex++) {
        if (dayOfWeekIndex == editedDayOfWeekIndex &&
            periodIndex == editedPeriodIndex) {
          newTimetable[dayOfWeekIndex.toString()]!.add(editedTimeTableEntry);
        } else {
          newTimetable[dayOfWeekIndex.toString()]!.add(
              (institutionClass.timeTable[dayOfWeekIndex.toString()] != null &&
                      institutionClass
                              .timeTable[dayOfWeekIndex.toString()]!.length >
                          periodIndex)
                  ? institutionClass
                      .timeTable[dayOfWeekIndex.toString()]![periodIndex]
                  : const TimetableEntry(subject: '', teacherId: ''));
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
    String? periodId,
  }) async {
    //1. get all students in the class
    final studentsSnapshot =
        await DbService.classStudentsQueryRef(institutionClassId).get();
    final students = studentsSnapshot.docs.map((doc) => doc.data()).toList();

    final studentIds = students.map((student) => student.id).toList();

    final startOfDay = DateTime(date.year, date.month, date.day);
    final startOfTomorrow = DateTime(date.year, date.month, date.day + 1);

    Query<Attendance> query = DbService.attendancesCollRef()
        .where('userId', whereIn: studentIds)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(startOfTomorrow));

    if (periodId != null) {
      query = query.where('periodId', isEqualTo: periodId);
    }

    final attendancesSnapshot = await query.get();

    //3. return the attendances
    return attendancesSnapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<Map<String, AppUser>> fetchClassStudents({
    required String classId,
  }) async {
    final studentsSnapshot =
        await DbService.classStudentsQueryRef(classId).get();

    return studentsSnapshot.docs.fold<Map<String, AppUser>>(
      {},
      (acc, doc) => acc..[doc.id] = doc.data(),
    );
  }

  static Future<String> createClass({
    required String institutionId,
    required String className,
  }) async {
    final newClassDoc = DbService.classesCollRef().doc();

    // Initialize empty timetable with 7 days (0-6)
    Map<String, List<TimetableEntry>> emptyTimeTable = {};
    for (int dayOfWeekIndex = 0; dayOfWeekIndex < 7; dayOfWeekIndex++) {
      emptyTimeTable[dayOfWeekIndex.toString()] = [];
    }

    final now = DateTime.now();

    final newInstitutionClass = InstitutionClass(
      id: newClassDoc.id,
      institutionId: institutionId,
      name: className,
      timeTable: emptyTimeTable,
      studentIds: [],
      createdAt: now,
      updatedAt: now,
    );

    await newClassDoc.set(newInstitutionClass);
    return newClassDoc.id;
  }

  static Future<void> addStudentToClass({
    required String studentId,
    required String classId,
  }) async {
    // Update student's classId
    final userDoc = DbService.usersCollRef().doc(studentId);

    // Update class's studentIds list
    final classDoc = DbService.classesCollRef().doc(classId);
    final classData = await classDoc.get();
    final institutionClass = classData.data();

    if (institutionClass != null) {
      // Use a batch to ensure both updates happen atomically
      final batch = DbService.db.batch();

      // Update student document
      batch.update(userDoc, {
        'classId': classId,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Update class document with the new student ID
      final updatedStudentIds = [...institutionClass.studentIds];
      if (!updatedStudentIds.contains(studentId)) {
        updatedStudentIds.add(studentId);
      }

      batch.update(classDoc, {
        'studentIds': updatedStudentIds,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await batch.commit();
    } else {
      throw Exception('Class not found');
    }
  }

  static Future<Map<String, AppUser>> fetchInstitutionStudentsWithoutClass({
    required String institutionId,
  }) async {
    final studentsSnapshot = await DbService.usersCollRef()
        .where('institutionId', isEqualTo: institutionId)
        .where('role', isEqualTo: UserRole.student.name)
        .get();

    final filteredDocs = studentsSnapshot.docs.where((doc) {
      final data = doc.data();
      return data.classId == null;
    }).toList();

    return filteredDocs.fold<Map<String, AppUser>>(
      {},
      (acc, doc) => acc..[doc.id] = doc.data(),
    );
  }

  static Future<void> removeStudentFromClass({
    required String studentId,
    required String classId,
  }) async {
    // Get references to both documents
    final userDoc = DbService.usersCollRef().doc(studentId);
    final classDoc = DbService.classesCollRef().doc(classId);

    // Get the class data
    final classData = await classDoc.get();
    final institutionClass = classData.data();

    if (institutionClass != null) {
      // Use a batch to ensure both updates happen atomically
      final batch = DbService.db.batch();

      // Update student document - remove classId
      batch.update(userDoc, {
        'classId': null, // Setting to null to indicate not in any class
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Update class document - remove student from list
      final updatedStudentIds = [...institutionClass.studentIds];
      updatedStudentIds.remove(studentId);

      batch.update(classDoc, {
        'studentIds': updatedStudentIds,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await batch.commit();
    } else {
      throw Exception('Class not found');
    }
  }
}
