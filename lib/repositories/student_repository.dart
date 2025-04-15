import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/constants/listing_limit.dart';
import 'package:potential_plus/models/activity.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/services/db_service.dart';

class StudentRepository {
  static Stream<List<Activity>> fetchUserActivitiesStreamWithLimit(
      String userId) {
    log('Fetching activities for user: $userId with limit: $LISTING_LIMIT');
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

  static Future<List<Activity>> fetchUserActivitiesBeforeDate(
      String userId, DateTime lastActivityDate) async {
    final activitiesSnapshot = await DbService.activitiesCollRef()
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .startAfter([Timestamp.fromDate(lastActivityDate)])
        .limit(LISTING_LIMIT)
        .get();

    return activitiesSnapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<Attendance> fetchActivityDetails(
      String activityId, String type) async {
    if (type != 'attendance') {
      throw Exception('Unsupported activity type: $type');
    }

    final doc = await FirebaseFirestore.instance
        .collection('attendance')
        .doc(activityId)
        .get();

    if (!doc.exists) {
      throw Exception('Activity details not found');
    }

    return Attendance.fromFirestore(doc);
  }
}
