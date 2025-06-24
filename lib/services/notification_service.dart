import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// NotificationType enum to identify different types of notifications
enum NotificationType {
  attendanceUpdate,
  newAttendance,
  announcement,
  general,
  unknown
}

/// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// A service to handle different types of notifications received from Firebase
class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Local notifications plugin
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Stream controllers for different notification types
  final Stream<RemoteMessage> onMessageStream = FirebaseMessaging.onMessage;
  final Stream<RemoteMessage> onMessageOpenedAppStream =
      FirebaseMessaging.onMessageOpenedApp;

  /// Initialize the notification service
  Future<void> initialize() async {
    // Initialize local notifications
    await _setupLocalNotifications();

    // Setup message handlers for different notification types
    _setupMessageHandlers();
  }

  /// Setup local notifications
  Future<void> _setupLocalNotifications() async {
    // Initialize Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    // Create Android notification channel
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize local notifications
    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
        // Here you could parse the payload and navigate to a specific screen
      },
    );

    debugPrint('Local notifications initialized in NotificationService');
  }

  /// Setup handlers for different message types
  void _setupMessageHandlers() {
    // Listen for foreground messages
    onMessageStream.listen((RemoteMessage message) {
      _processNotification(message);
    });

    // When app is opened from a notification while in background
    onMessageOpenedAppStream.listen((RemoteMessage message) {
      _processNotificationTap(message);
    });

    // Handle initial notification if app was terminated
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _processNotificationTap(message);
      }
    });
  }

  /// Process an incoming notification based on its type
  void _processNotification(RemoteMessage message) {
    final notificationType = _getNotificationType(message);

    switch (notificationType) {
      case NotificationType.attendanceUpdate:
        _handleAttendanceNotification(message);
        break;
      case NotificationType.newAttendance:
        _handleAttendanceNotification(message);
        break;
      case NotificationType.announcement:
        _handleAnnouncementNotification(message);
        break;
      default:
        // For general or unknown notifications, just show them
        showLocalNotification(message);
    }
  }

  /// Process a notification that was tapped by the user
  void _processNotificationTap(RemoteMessage message) {
    final notificationType = _getNotificationType(message);

    switch (notificationType) {
      case NotificationType.attendanceUpdate:
      case NotificationType.newAttendance:
        // Navigate to attendance screen or refresh attendance data
        debugPrint('Navigating to attendance screen from notification tap');
        // You can implement navigation logic here or use a callback
        break;
      case NotificationType.announcement:
        // Navigate to announcements screen
        debugPrint('Navigating to announcements screen from notification tap');
        break;
      default:
        debugPrint('Processing general notification tap');
    }
  }

  /// Show a local notification from a remote message
  void showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      _localNotificationsPlugin.show(
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
      debugPrint('Local notification shown from NotificationService');
    }
  }

  /// Determine the type of notification from the message data
  NotificationType _getNotificationType(RemoteMessage message) {
    // First check if the notification type is specified in data
    if (message.data.containsKey('type')) {
      final type = message.data['type'];

      if (type == 'attendance') {
        return NotificationType.attendanceUpdate;
      } else if (type == 'new_attendance') {
        return NotificationType.newAttendance;
      } else if (type == 'announcement') {
        return NotificationType.announcement;
      }
    }

    // Check if there are specific keys that indicate the notification type
    if (message.data.containsKey('attendanceId')) {
      return NotificationType.attendanceUpdate;
    } else if (message.data.containsKey('announcementId')) {
      return NotificationType.announcement;
    }

    // If the notification title contains specific words
    final title = message.notification?.title?.toLowerCase() ?? '';
    if (title.contains('attendance')) {
      return NotificationType.attendanceUpdate;
    } else if (title.contains('announcement')) {
      return NotificationType.announcement;
    }

    // Default to general notification type
    return NotificationType.general;
  }

  /// Handle attendance notifications
  void _handleAttendanceNotification(RemoteMessage message) {
    // Show the notification
    showLocalNotification(message);

    // You can trigger attendance data refresh here
    debugPrint(
        'Handling attendance notification: ${message.notification?.title}');

    // Extract attendance details from message data
    final isPresent = message.data['isPresent'] == 'true';
    final attendanceId = message.data['attendanceId'];

    // You can trigger state updates or other actions here
    // For example, refresh the attendance list in the UI
  }

  /// Handle announcement notifications
  void _handleAnnouncementNotification(RemoteMessage message) {
    // Show the notification
    showLocalNotification(message);

    // You can trigger announcement data refresh here
    debugPrint(
        'Handling announcement notification: ${message.notification?.title}');

    // Extract announcement details from message data
    final announcementId = message.data['announcementId'];

    // You can trigger state updates or other actions here
  }
}
