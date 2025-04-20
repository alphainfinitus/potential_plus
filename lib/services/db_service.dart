import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/models/activity.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:uuid/uuid.dart';

class DbService {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // Generic method for creating collection references
  static CollectionReference<T> _collectionRef<T>(
    String collectionPath,
    T Function(Map<String, dynamic>) fromMap,
    Map<String, dynamic> Function(T) toMap,
  ) {
    return db.collection(collectionPath).withConverter(
          fromFirestore: (snapshot, _) => fromMap(snapshot.data()!),
          toFirestore: (value, _) => toMap(value),
        );
  }

  // Collection references
  static CollectionReference<AppUser> usersCollRef() =>
      _collectionRef('users', AppUser.fromMap, (user) => user.toMap());

  static CollectionReference<Institution> institutionsCollRef() =>
      _collectionRef('institutions', Institution.fromMap,
          (institution) => institution.toMap());

  static CollectionReference<Activity> activitiesCollRef() => _collectionRef(
      'activities', Activity.fromMap, (activity) => activity.toMap());

  static CollectionReference<Attendance> attendancesCollRef() => _collectionRef(
      'attendances', Attendance.fromMap, (attendance) => attendance.toMap());

  static CollectionReference<InstitutionClass> classesCollRef() =>
      _collectionRef('classes', InstitutionClass.fromMap,
          (institutionClass) => institutionClass.toMap());

  static CollectionReference<TimeTable> timeTablesCollRef() => _collectionRef(
      'timetable', TimeTable.fromMap, (timeTable) => timeTable.toMap());

  //queries
  static Query<AppUser> _institutionUserQueryRef(
          String institutionId, UserRole role) =>
      usersCollRef()
          .where('institutionId', isEqualTo: institutionId)
          .where('role', isEqualTo: role.name);

  static Query<AppUser> institutionTeachersQueryRef(String institutionId) =>
      _institutionUserQueryRef(institutionId, UserRole.teacher);

  static Query<AppUser> classStudentsQueryRef(String classId) => usersCollRef()
      .where('classId', isEqualTo: classId)
      .where('role', isEqualTo: UserRole.student.name);

  static Query<Attendance> attendanceForDateQueryRef({
    required String userId,
    required String institutionId,
    required DateTime date,
  }) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final startOfTomorrow = DateTime(date.year, date.month, date.day + 1);

    return attendancesCollRef()
        .where('userId', isEqualTo: userId)
        .where('institutionId', isEqualTo: institutionId)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(startOfTomorrow))
        .withConverter(
          fromFirestore: (snapshot, _) => Attendance.fromMap(snapshot.data()!),
          toFirestore: (Attendance attendance, _) => attendance.toMap(),
        );
  }

  static Query<Activity> activityByActivityRefIdQueryRef(String activityRefId) {
    return activitiesCollRef().where('activityRefId', isEqualTo: activityRefId);
  }

  // Timetable related methods
  static Future<TimeTable?> getClassTimetable(String classId) async {
    var classDoc = await classesCollRef().where('id', isEqualTo: classId).get();
    if (classDoc.docs.isEmpty) {
      return null;
    }
    var classData = classDoc.docs.first.data();
    var timetableId = classData.timeTable;
    log('timetableId: $timetableId');
    try {
      if (timetableId == null) {
        final uuid = const Uuid().v4(); // Generate a UUID
        final newTimetable = TimeTable(
          id: uuid,
          entries: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await timeTablesCollRef().doc(uuid).set(newTimetable);
        classDoc.docs.first.reference.update({'timeTable': uuid});
        return newTimetable;
      }
      final querySnapshot =
          await timeTablesCollRef().where('id', isEqualTo: timetableId).get();

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      return TimeTable(
        id: data.id,
        entries: data.entries,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateClassTimetable(
      String timetableId, TimeTable timetable) async {
    try {
      final querySnapshot =
          await timeTablesCollRef().where('id', isEqualTo: timetableId).get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Timetable not found');
      }
      final doc = querySnapshot.docs.first;
      await doc.reference.update({
        'entries': timetable.entries.map((e) => e.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Error updating timetable: $e');
      rethrow;
    }
  }

  static Stream<TimeTable?> streamClassTimetable(String timetableId) {
    return timeTablesCollRef()
        .where('id', isEqualTo: timetableId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = doc.data();
      return TimeTable(
        id: data.id,
        entries: (data.entries as List)
            .map((entry) => TimetableEntry.fromMap(entry))
            .toList(),
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      );
    });
  }
}
