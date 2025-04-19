import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/models/activity/activity.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';

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
      'temp_activities', Activity.fromMap, (activity) => activity.toMap());

  static CollectionReference<Attendance> attendancesCollRef() => _collectionRef(
      'attendances', Attendance.fromMap, (attendance) => attendance.toMap());

  static CollectionReference<InstitutionClass> classesCollRef() =>
      _collectionRef('classes', InstitutionClass.fromMap,
          (institutionClass) => institutionClass.toMap());

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

  static Query<Attendance> attendanceForPeriodQueryRef({
    required String userId,
    required String institutionId,
    required String periodId,
    required DateTime date,
  }) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final startOfTomorrow = DateTime(date.year, date.month, date.day + 1);

    return attendancesCollRef()
        .where('userId', isEqualTo: userId)
        .where('institutionId', isEqualTo: institutionId)
        .where('periodId', isEqualTo: periodId)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(startOfTomorrow))
        .withConverter(
          fromFirestore: (snapshot, _) => Attendance.fromMap(snapshot.data()!),
          toFirestore: (Attendance attendance, _) => attendance.toMap(),
        );
  }
}
