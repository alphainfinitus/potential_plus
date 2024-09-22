import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/constants/activity_type.dart';
import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/models/activity.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';

class DbService {
  static final db = FirebaseFirestore.instance;

  //refs
  static CollectionReference<AppUser> usersCollRef() => db
		.collection('users')
		.withConverter(
			fromFirestore: (snapshot, _) => AppUser.fromMap(snapshot.data()!),
			toFirestore: (AppUser user, _) => user.toMap(),
		);

  static CollectionReference<Institution> institutionsCollRef() => db
		.collection('institutions')
		.withConverter(
			fromFirestore: (snapshot, _) => Institution.fromMap(snapshot.data()!),
			toFirestore: (Institution user, _) => user.toMap(),
		);

  static CollectionReference<Activity> activitiesCollRef() => db
		.collection('activities')
		.withConverter(
			fromFirestore: (snapshot, _) => Activity.fromMap(snapshot.data()!),
			toFirestore: (Activity activity, _) => activity.toMap(),
		);

  static CollectionReference<Attendance> attendancesCollRef() => db
		.collection('attendances')
		.withConverter(
			fromFirestore: (snapshot, _) => Attendance.fromMap(snapshot.data()!),
			toFirestore: (Attendance attendance, _) => attendance.toMap(),
		);

  static CollectionReference<InstitutionClass> institutionClassesCollRef(String institutionId) => db
		.collection('institutions')
		.doc(institutionId)
		.collection('classes')
		.withConverter(
			fromFirestore: (snapshot, _) => InstitutionClass.fromMap(snapshot.data()!),
			toFirestore: (InstitutionClass institutionClass, _) => institutionClass.toMap(),
		);

  //queries
  static Query<AppUser> institutionTeachersQueryRef(String institutionId) => db
      .collection('users')
      .where('institutionId', isEqualTo: institutionId)
      .where('role', isEqualTo: UserRole.teacher.name)
      .withConverter(
        fromFirestore: (snapshot, _) => AppUser.fromMap(snapshot.data()!),
        toFirestore: (AppUser user, _) => user.toMap(),
      );

  static Query<AppUser> institutionStudentsQueryRef(String institutionId) => db
      .collection('users')
      .where('institutionId', isEqualTo: institutionId)
      .where('role', isEqualTo: UserRole.student.name)
      .withConverter(
        fromFirestore: (snapshot, _) => AppUser.fromMap(snapshot.data()!),
        toFirestore: (AppUser user, _) => user.toMap(),
      );

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
			.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
			.where('createdAt', isLessThan: Timestamp.fromDate(startOfTomorrow))
			.withConverter(
				fromFirestore: (snapshot, _) => Attendance.fromMap(snapshot.data()!),
				toFirestore: (Attendance attendance, _) => attendance.toMap(),
			);
  }

  static Query<Activity> activityByActivityRefIdQueryRef(String activityRefId) {
		return activitiesCollRef().where('activityRefId', isEqualTo: activityRefId);
	}

  // Methods
  static Future<AppUser?> fetchUserData(String userId) async {
    final userDoc = await usersCollRef().doc(userId).get();
    return userDoc.data();
  }

  static Future<Institution?> fetchInstitutionData(String institutionId) async {
    final institutionDoc = await institutionsCollRef().doc(institutionId).get();
    return institutionDoc.data();
  }

  // returns a map with key of institutionClassId and value of InstitutionClass
  static Future<Map<String, InstitutionClass>> fetchClassesForInstitution(String institutionId) async {
    final institutionClassesSnapshot = await institutionClassesCollRef(institutionId).get();
    return institutionClassesSnapshot.docs.fold<Map<String, InstitutionClass>>(
      {},
      (acc, doc) => acc..[doc.id] = doc.data(),
    );
  }

  // returns a map with key of teacherId and value of AppUser
  static Future<Map<String, AppUser>> fetchTeachersForInstitution(String institutionId) async {
    final teachersSnapshot = await institutionTeachersQueryRef(institutionId).get();
    return teachersSnapshot.docs.fold<Map<String, AppUser>>(
      {},
      (acc, doc) => acc..[doc.id] = doc.data(),
    );
  }

  // returns a map with key of studentId and value of AppUser
  static Future<Map<String, AppUser>> fetchStudentsForInstitution(String institutionId) async {
    final studentsSnapshot = await institutionStudentsQueryRef(institutionId).get();
    return studentsSnapshot.docs.fold<Map<String, AppUser>>(
      {},
      (acc, doc) => acc..[doc.id] = doc.data(),
    );
  }

  // TODO : convert all functions to use named parameters
  static Future updateClassPeriodDetails(
    String institutionId,
    String institutionClassId,
    Map<String, List<TimetableEntry>> newTimeTable,
  ) async {
    final institutionClassRef = institutionClassesCollRef(institutionId).doc(institutionClassId);

    // TODO: optimise this to only update the specific period
    await institutionClassRef.update({
      'timeTable': newTimeTable.map(
				(key, value) => MapEntry(key, value.map((e) => e.toMap()).toList())
			),
    });
  }

  static Future updateStudentAttendance({
    required String studentId,
    required bool isPresent,
    required String institutionId,
    required String markedByUserId,
  }) async {
    // TODO: use transactions to ensure atomicity
    // TODO: control flow is too messy, refactor

    final batch = db.batch();

    // 1. check if attendance already exists for today
    final todayAttendanceSnapshot = (await attendanceForDateQueryRef(userId: studentId, institutionId: institutionId, date: DateTime.now()).limit(1).get()).docs.firstOrNull;

    // 2. if it exists, update the attendance and the corresponding activity
    if (todayAttendanceSnapshot != null) {
      batch.update(todayAttendanceSnapshot.reference, {
        'isPresent': isPresent,
        'markedByUserId': markedByUserId,
        'updatedAt': Timestamp.now(),
      });

      // 2.1. update the corresponding activity
      final activitySnapshot = await activityByActivityRefIdQueryRef(todayAttendanceSnapshot.id).limit(1).get();
      final activity = activitySnapshot.docs.firstOrNull;

      if (activity != null) {
        batch.update(activity.reference, {
          'updatedAt': Timestamp.now(),
        });
      }
      // 2.2. create an activity for the attendance
      else {
        final newActivityDoc = activitiesCollRef().doc();

        final newActivity = Activity(
          id: newActivityDoc.id,
          userId: studentId,
          activityType: ActivityType.attendance,
          activityRefId: todayAttendanceSnapshot.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        batch.set(newActivityDoc, newActivity);
      }
    }
    // 3. if it doesn't exist, create it
    else {
      final newAttendanceDoc = attendancesCollRef().doc();

      final newAttendance = Attendance(
        id: newAttendanceDoc.id,
        userId: studentId,
        institutionId: institutionId,
        isPresent: isPresent,
        markedByUserId: markedByUserId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      batch.set(newAttendanceDoc, newAttendance);

      // 4. create an activity for the attendance
      final newActivityDoc = activitiesCollRef().doc();

      final newActivity = Activity(
        id: newActivityDoc.id,
        userId: studentId,
        activityType: ActivityType.attendance,
        activityRefId: newAttendanceDoc.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      batch.set(newActivityDoc, newActivity);
    }

    await batch.commit();
  }

	static Future<List<Attendance>> fetchClassAttendanceByDate({
		required String institutionId,
		required String institutionClassId,
		required DateTime date,
	}) async {
		//1. get all students in the class
		final studentsSnapshot = await institutionStudentsQueryRef(institutionId).get();
		final students = studentsSnapshot.docs.map((doc) => doc.data()).toList();

		final studentIds = students.map((student) => student.id).toList();

		final startOfDay = DateTime(date.year, date.month, date.day);
    final startOfTomorrow = DateTime(date.year, date.month, date.day + 1);

		final attendancesSnapshot = await attendancesCollRef()
      .where('institutionId', isEqualTo: institutionId)
      .where('userId', whereIn: studentIds)
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('createdAt', isLessThan: Timestamp.fromDate(startOfTomorrow))
      .get();

		//3. return the attendances
		return attendancesSnapshot.docs.map((doc) => doc.data()).toList();
	}
}
