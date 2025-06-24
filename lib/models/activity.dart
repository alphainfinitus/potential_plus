import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/constants/activity_type.dart';

class Activity {
  const Activity({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.activityRefId,
    required this.targetType,
    required this.createdAt,
    required this.updatedAt,
    required this.institutionId,
    this.title,
    this.message,
    this.specificUserId,
  });

  final String id;
  final String userId;
  final ActivityType activityType;
  final String activityRefId;
  final TargetType targetType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String institutionId;
  final String? title;
  final String? message;
  final String? specificUserId;

  factory Activity.fromMap(Map<String, dynamic> data) {
    ActivityType activityType =
        ActivityType.values.byName(data['activityType']);

    return Activity(
      id: data['id'],
      userId: data['userId'],
      activityType: activityType,
      activityRefId: data['activityRefId'],
      targetType: TargetType.values.byName(data['targetType']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      institutionId: data['institutionId'],
      title: data['title'],
      message: data['message'],
      specificUserId: data['specificUserId'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'activityType': activityType.name,
        'activityRefId': activityRefId,
        'targetType': targetType.name,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'institutionId': institutionId,
        'title': title,
        'message': message,
        'specificUserId': specificUserId,
      };
}
