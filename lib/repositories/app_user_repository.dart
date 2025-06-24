import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/services/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserRepository {
  static Future<AppUser?> fetchUserData(String userId) async {
    final userDoc = await DbService.usersCollRef().doc(userId).get();
    return userDoc.data();
  }

  // Update FCM token for a user
  static Future<void> updateFcmToken(String userId, String token) async {
    try {
      await DbService.usersCollRef().doc(userId).update({
        'fcmToken': token,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

  // Remove FCM token from a user (e.g., on logout)
  static Future<void> removeFcmToken(String userId) async {
    try {
      await DbService.usersCollRef().doc(userId).update({
        'fcmToken': FieldValue.delete(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to remove FCM token: $e');
    }
  }
}
