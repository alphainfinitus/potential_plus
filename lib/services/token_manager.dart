import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:potential_plus/repositories/app_user_repository.dart';

/// A service class to manage FCM tokens using SharedPreferences
class TokenManager {
  static const String _fcmTokenKey = 'fcm_token';

  /// Verify and update token on dashboard page
  static Future<void> verifyTokenOnDashboard() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Get current token from FCM
      String? currentToken = await FirebaseMessaging.instance.getToken();
      if (currentToken == null) return;

      // Get saved token from shared preferences
      String? savedToken = await getSavedToken();

      // If tokens don't match or saved token is null, update
      if (savedToken != currentToken) {
        await saveTokenToPrefs(currentToken);
        await AppUserRepository.updateFcmToken(currentUser.uid, currentToken);
        debugPrint('FCM token updated on dashboard: $currentToken');
      } else {
        debugPrint('FCM token verification: token is up to date');
      }
    } catch (e) {
      debugPrint('Error verifying FCM token: $e');
    }
  }

  /// Save token to shared preferences
  static Future<void> saveTokenToPrefs(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fcmTokenKey, token);
      debugPrint('FCM token saved to shared preferences');
    } catch (e) {
      debugPrint('Error saving FCM token to preferences: $e');
    }
  }

  /// Get token from shared preferences
  static Future<String?> getSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_fcmTokenKey);
    } catch (e) {
      debugPrint('Error getting FCM token from preferences: $e');
      return null;
    }
  }

  /// Remove token from shared preferences
  static Future<void> removeSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fcmTokenKey);
      debugPrint('FCM token removed from shared preferences');
    } catch (e) {
      debugPrint('Error removing FCM token from preferences: $e');
    }
  }
}
