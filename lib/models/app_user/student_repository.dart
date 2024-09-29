import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/constants/activity_type.dart';
import 'package:potential_plus/constants/listing_limit.dart';
import 'package:potential_plus/models/activity/activity.dart';
import 'package:potential_plus/models/attendance/attendance.dart';
import 'package:potential_plus/services/db_service.dart';

class StudentRepository {
  static Stream<List<Activity>> fetchUserActivitiesStreamWithLimit(String userId) {
    return DbService.activitiesCollRef()
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(LISTING_LIMIT)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  static Stream<List<Activity>> fetchUserActivitiesStream(String userId) {
    return DbService.activitiesCollRef()
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  static Future<List<Activity>> fetchUserActivitiesBeforeDate(String userId, DateTime lastActivityDate) async {
    final activitiesSnapshot = await DbService.activitiesCollRef()
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .startAfter([Timestamp.fromDate(lastActivityDate)])
        .limit(LISTING_LIMIT)
        .get();

    return activitiesSnapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<Attendance> fetchActivityDetails(String activityId, ActivityType activityType) async {
    switch (activityType) {
      case ActivityType.attendance:
        final attendanceSnapshot = await DbService.attendancesCollRef().doc(activityId).get();
        return attendanceSnapshot.data()!;
      default:
        throw Exception('Invalid activity type');
    }
  }
}