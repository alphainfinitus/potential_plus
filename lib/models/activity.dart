import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/constants/activity_type.dart';

class Activity {
  const Activity({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.activityRefId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final ActivityType activityType;
  final String activityRefId;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Activity.fromMap(Map<String, dynamic> data) {
    ActivityType activityType = ActivityType.values.byName(data['activityType']);

    return Activity(
      id: data['id'],
      userId: data['userId'],
      activityType: activityType,
      activityRefId: data['activityRefId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'activityType': activityType.toString(),
    'activityRefId': activityRefId,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
