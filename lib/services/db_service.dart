import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/constants/activity_type.dart';
import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/models/activity.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:cuid2/cuid2.dart';

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
    var timetableId = classData.timeTableId;
    try {
      final querySnapshot =
          await timeTablesCollRef().where('id', isEqualTo: timetableId).get();

      final doc = querySnapshot.docs.first;
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateClassTimetable(
      String timetableId, TimeTable timetable) async {
    try {
      final querySnapshot =
          await timeTablesCollRef().where('id', isEqualTo: timetableId).get();
      final doc = querySnapshot.docs.first;
      await doc.reference.set(
        timetable,
        SetOptions(merge: true),
      );
    } catch (e) {
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

  // Add new attendance-related queries
  static Query<Attendance> lectureAttendanceQueryRef({
    required String classId,
    required String timeTableEntryId,
    required DateTime date,
  }) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final startOfTomorrow = DateTime(date.year, date.month, date.day + 1);

    return attendancesCollRef()
        .where('classId', isEqualTo: classId)
        .where('metaData.timeTableEntryId', isEqualTo: timeTableEntryId)
        .where('dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dateTime', isLessThan: Timestamp.fromDate(startOfTomorrow));
  }

  static Future<void> markAttendance({
    required String institutionId,
    required String classId,
    required String timeTableId,
    required String timeTableEntryId,
    required List<Map<String, dynamic>> attendanceData,
    required DateTime date,
  }) async {
    final batch = db.batch();
    final now = DateTime.now();

    final existingAttendanceQuery = await lectureAttendanceQueryRef(
      classId: classId,
      timeTableEntryId: timeTableEntryId,
      date: date,
    ).get();

    final existingAttendanceMap = {
      for (var doc in existingAttendanceQuery.docs)
        doc.data().userId: doc.data()
    };

    for (final data in attendanceData) {
      final userId = data['userId'] as String;
      final existingAttendance = existingAttendanceMap[userId];

      final attendance = existingAttendance != null
          ? existingAttendance.copyWith(
              isPresent: data['isPresent'],
              updatedAt: now,
            )
          : Attendance(
              id: cuid(),
              userId: userId,
              institutionId: institutionId,
              classId: classId,
              isPresent: data['isPresent'],
              markedByUserId: data['markedByUserId'],
              dateTime: date,
              createdAt: now,
              updatedAt: now,
              metaData: MetaData(
                subject: data['subject'],
                timeTableId: timeTableId,
                timeTableEntryId: timeTableEntryId,
              ),
            );

      final docRef = attendancesCollRef().doc(attendance.id);
      batch.set(docRef, attendance);
    }

    await batch.commit();
  }

  static Future<Map<String, bool>> getLectureAttendance({
    required String classId,
    required String timeTableEntryId,
    required DateTime date,
  }) async {
    final querySnapshot = await lectureAttendanceQueryRef(
      classId: classId,
      timeTableEntryId: timeTableEntryId,
      date: date,
    ).get();

    final attendanceMap = <String, bool>{};
    for (final doc in querySnapshot.docs) {
      final attendance = doc.data();
      attendanceMap[attendance.userId] = attendance.isPresent;
    }

    return attendanceMap;
  }

  // Announcement related methods
  static Future<List<Activity>> getInstitutionAnnouncements(
      String institutionId) async {
    print('Fetching announcements for institution: $institutionId');

    try {
      // First check if we need to make a more basic query
      final testQuery = await activitiesCollRef().limit(10).get();

      print('Basic query found ${testQuery.docs.length} activities in total');

      // Try a simpler query first
      final basicQuery = await activitiesCollRef()
          .where('institutionId', isEqualTo: institutionId)
          .get();

      print(
          'Basic institution query found ${basicQuery.docs.length} activities');

      // Now try the full query
      final querySnapshot = await activitiesCollRef()
          .where('institutionId', isEqualTo: institutionId)
          .where('activityType', isEqualTo: ActivityType.announcement.name)
          .orderBy('createdAt', descending: true)
          .get();

      print('Full query found ${querySnapshot.docs.length} announcements');

      final result = querySnapshot.docs.map((doc) => doc.data()).toList();
      return result;
    } catch (e) {
      print('Error fetching announcements: $e');
      // Try a fallback approach - get all activities and filter in memory
      try {
        print('Trying fallback approach...');
        final allActivities = await activitiesCollRef().get();

        print(
            'Got ${allActivities.docs.length} total activities, filtering in memory');

        return allActivities.docs
            .map((doc) => doc.data())
            .where((activity) =>
                activity.institutionId == institutionId &&
                activity.activityType == ActivityType.announcement)
            .toList();
      } catch (fallbackError) {
        print('Fallback also failed: $fallbackError');
        return [];
      }
    }
  }

  static Stream<List<Activity>> streamInstitutionAnnouncements(
      String institutionId) {
    return activitiesCollRef()
        .where('institutionId', isEqualTo: institutionId)
        .where('activityType', isEqualTo: ActivityType.announcement.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  static Future<List<Activity>> getUserAnnouncements(
      String userId, UserRole userRole, String institutionId) async {
    try {
      // Get announcements for all
      final allAnnouncementsQuery = await activitiesCollRef()
          .where('institutionId', isEqualTo: institutionId)
          .where('activityType', isEqualTo: ActivityType.announcement.name)
          .where('targetType', isEqualTo: TargetType.ALL.name)
          .get();

      // Get role-specific announcements (students or teachers)
      final String roleTargetType = userRole == UserRole.student
          ? TargetType.ALL_STUDENTS.name
          : TargetType.ALL_TEACHERS.name;

      final roleAnnouncementsQuery = await activitiesCollRef()
          .where('institutionId', isEqualTo: institutionId)
          .where('activityType', isEqualTo: ActivityType.announcement.name)
          .where('targetType', isEqualTo: roleTargetType)
          .get();

      // Get user-specific announcements
      final userAnnouncementsQuery = await activitiesCollRef()
          .where('institutionId', isEqualTo: institutionId)
          .where('activityType', isEqualTo: ActivityType.announcement.name)
          .where('specificUserId', isEqualTo: userId)
          .get();

      List<Activity> announcements = [
        ...allAnnouncementsQuery.docs.map((doc) => doc.data()),
        ...roleAnnouncementsQuery.docs.map((doc) => doc.data()),
        ...userAnnouncementsQuery.docs.map((doc) => doc.data()),
      ];

      // Sort by createdAt descending
      announcements.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return announcements;
    } catch (e) {
      print('Error fetching user announcements: $e');
      return [];
    }
  }

  static Future<List<AppUser>> getInstitutionStudents(
      String institutionId) async {
    try {
      final querySnapshot = await usersCollRef()
          .where('institutionId', isEqualTo: institutionId)
          .where('role', isEqualTo: UserRole.student.name)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<AppUser>> getInstitutionTeachers(
      String institutionId) async {
    try {
      final querySnapshot = await usersCollRef()
          .where('institutionId', isEqualTo: institutionId)
          .where('role', isEqualTo: UserRole.teacher.name)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching teachers: $e');
      return [];
    }
  }
}
