import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:potential_plus/repositories/app_user_repository.dart';
import 'package:potential_plus/services/token_manager.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
        'User notification permission status: ${settings.authorizationStatus}');

    // Initialize local notifications first
    await _setupLocalNotifications();

    // Configure message handlers
    _configureMessageHandlers();

    // Save FCM token to user document and SharedPreferences
    await saveToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      _updateToken(token);
    });
  }

  static void _configureMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          'Received message in foreground: ${message.notification?.title}');
      // Display the notification when app is in foreground
      _showLocalNotification(message);
    });

    // When app is opened from a notification while in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          'App opened from notification: ${message.notification?.title}');
      // Handle navigation if needed
    });

    // Handle initial notification if app was terminated
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        debugPrint(
            'App started from notification: ${message.notification?.title}');
        // Handle navigation if needed
      }
    });
  }

  static Future<void> _setupLocalNotifications() async {
    // Initialize Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    // Create Android notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize local notifications
    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
        // Here you could parse the payload and navigate to a specific screen
      },
    );

    debugPrint('Local notifications initialized');
  }

  static void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: const AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
      debugPrint('Local notification shown');
    }
  }

  // Get and save FCM token
  static Future<void> saveToken() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      String? token = await _messaging.getToken();
      if (token == null) return;

      // Save to SharedPreferences
      await TokenManager.saveTokenToPrefs(token);

      // Save to Firestore
      await AppUserRepository.updateFcmToken(currentUser.uid, token);
      debugPrint('FCM token saved for user: $token');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  // Update token when refreshed
  static Future<void> _updateToken(String token) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Save to SharedPreferences
      await TokenManager.saveTokenToPrefs(token);

      // Save to Firestore
      await AppUserRepository.updateFcmToken(currentUser.uid, token);
      debugPrint('FCM token updated: $token');
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  // Remove token on logout
  static Future<void> removeToken() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Remove from SharedPreferences
      await TokenManager.removeSavedToken();

      // Remove from Firestore
      await AppUserRepository.removeFcmToken(currentUser.uid);
      debugPrint('FCM token removed');
    } catch (e) {
      debugPrint('Error removing FCM token: $e');
    }
  }

  // Subscribe to a topic (e.g., for group notifications)
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  // Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
}
