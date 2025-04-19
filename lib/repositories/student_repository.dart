import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/constants/listing_limit.dart';
import 'package:potential_plus/models/activity/activity.dart';
import 'package:potential_plus/services/db_service.dart';

class StudentRepository {
  static Stream<List<Activity>> fetchUserActivitiesStreamWithLimit(
      String userId) {
    log('Fetching activities for user: $userId with limit: $LISTING_LIMIT');
    return DbService.activitiesCollRef()
        .where('forUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(LISTING_LIMIT)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  static Stream<List<Activity>> fetchUserActivitiesStream(String userId) {
    return DbService.activitiesCollRef()
        .where('forUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  static Future<List<Activity>> fetchUserActivitiesBeforeDate(
      String userId, DateTime lastActivityDate) async {
    final activitiesSnapshot = await DbService.activitiesCollRef()
        .where('forUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .startAfter([Timestamp.fromDate(lastActivityDate)])
        .limit(LISTING_LIMIT)
        .get();

    return activitiesSnapshot.docs.map((doc) => doc.data()).toList();
  }

  static Future<Activity> fetchActivityDetails(String activityId) async {
    final doc = await DbService.activitiesCollRef().doc(activityId).get();

    if (!doc.exists) {
      throw Exception('Activity details not found');
    }

    return doc.data()!;
  }
}
