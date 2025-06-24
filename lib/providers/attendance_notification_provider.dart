import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:potential_plus/services/notification_service.dart';

/// State class for attendance notifications
class AttendanceNotificationState {
  final bool hasUnreadNotifications;
  final List<Map<String, dynamic>> recentNotifications;

  const AttendanceNotificationState({
    this.hasUnreadNotifications = false,
    this.recentNotifications = const [],
  });

  AttendanceNotificationState copyWith({
    bool? hasUnreadNotifications,
    List<Map<String, dynamic>>? recentNotifications,
  }) {
    return AttendanceNotificationState(
      hasUnreadNotifications:
          hasUnreadNotifications ?? this.hasUnreadNotifications,
      recentNotifications: recentNotifications ?? this.recentNotifications,
    );
  }
}

/// Provider for attendance notifications state
final attendanceNotificationProvider = StateNotifierProvider<
    AttendanceNotificationNotifier, AttendanceNotificationState>((ref) {
  return AttendanceNotificationNotifier(ref);
});

/// Notifier class to manage attendance notification state
class AttendanceNotificationNotifier
    extends StateNotifier<AttendanceNotificationState> {
  final Ref _ref;

  AttendanceNotificationNotifier(this._ref)
      : super(const AttendanceNotificationState()) {
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notificationType = _getNotificationType(message);

      if (notificationType == NotificationType.attendanceUpdate ||
          notificationType == NotificationType.newAttendance) {
        _handleAttendanceNotification(message);
      }
    });
  }

  NotificationType _getNotificationType(RemoteMessage message) {
    // First check if the notification type is specified in data
    if (message.data.containsKey('type')) {
      final type = message.data['type'];

      if (type == 'attendance') {
        return NotificationType.attendanceUpdate;
      } else if (type == 'new_attendance') {
        return NotificationType.newAttendance;
      }
    }

    // Check if there are specific keys that indicate the notification type
    if (message.data.containsKey('attendanceId')) {
      return NotificationType.attendanceUpdate;
    }

    // If the notification title contains attendance
    final title = message.notification?.title?.toLowerCase() ?? '';
    if (title.contains('attendance')) {
      return NotificationType.attendanceUpdate;
    }

    return NotificationType.unknown;
  }

  void _handleAttendanceNotification(RemoteMessage message) {
    try {
      // Extract relevant information from the notification
      final Map<String, dynamic> notificationData = {
        'title': message.notification?.title ?? 'Attendance Update',
        'body': message.notification?.body ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'isRead': false,
      };

      // Add any additional data from message.data
      message.data.forEach((key, value) {
        notificationData[key] = value;
      });

      // Update state with new notification
      final updatedNotifications = [
        notificationData,
        ...state.recentNotifications,
      ].take(10).toList(); // Keep only the 10 most recent notifications

      state = state.copyWith(
        hasUnreadNotifications: true,
        recentNotifications: updatedNotifications,
      );

      debugPrint(
          'Added attendance notification to state: ${message.notification?.title}');
    } catch (e) {
      debugPrint('Error handling attendance notification: $e');
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    if (!state.hasUnreadNotifications) return;

    final updatedNotifications = state.recentNotifications.map((notification) {
      return {...notification, 'isRead': true};
    }).toList();

    state = state.copyWith(
      hasUnreadNotifications: false,
      recentNotifications: updatedNotifications,
    );

    debugPrint('Marked all attendance notifications as read');
  }

  /// Mark a specific notification as read
  void markAsRead(int index) {
    if (index < 0 || index >= state.recentNotifications.length) return;

    final updatedNotifications = [...state.recentNotifications];
    updatedNotifications[index] = {
      ...updatedNotifications[index],
      'isRead': true
    };

    // Check if there are still unread notifications
    final hasUnread = updatedNotifications
        .any((notification) => notification['isRead'] == false);

    state = state.copyWith(
      hasUnreadNotifications: hasUnread,
      recentNotifications: updatedNotifications,
    );

    debugPrint('Marked attendance notification at index $index as read');
  }

  /// Clear all notifications
  void clearNotifications() {
    state = const AttendanceNotificationState();
    debugPrint('Cleared all attendance notifications');
  }
}
