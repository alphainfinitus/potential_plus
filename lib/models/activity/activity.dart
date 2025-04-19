import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/constants/activity_type.dart';
import 'package:potential_plus/models/activity/activity_data.dart';
import 'package:potential_plus/models/activity/activity_factory.dart';

class Activity {
  final String id;
  final String title;
  final ActivityType activityType;
  final String forUserId;
  final String description;
  final String userName;
  final String userId;
  final DateTime createdAt;
  final ActivityData? data;

  Activity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.activityType,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.forUserId,
    this.data,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      userId: data['userId'],
      userName: data['userName'],
      activityType: ActivityType.values.byName(data['activityType']),
      title: data['title'],
      description: data['description'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      forUserId: data['forUserId'],
      data: data['data'] != null
          ? activityDataFactories[
              ActivityType.values.byName(data['activityType'])]!(data['data'])
          : null,
    );
  }

  factory Activity.fromMap(Map<String, dynamic> data) {
    log(data.toString());
    return Activity(
      id: data['id'],
      userId: data['userId'],
      userName: data['userName'],
      activityType: ActivityType.values.byName(data['activityType']),
      title: data['title'],
      description: data['description'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      data: data['data'] != null
          ? activityDataFactories[
              ActivityType.values.byName(data['activityType'])]!(data['data'])
          : null,
      forUserId: data['forUserId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'activityType': activityType.name,
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'data': data?.toMap(),
      'forUserId': forUserId,
    };
  }
}
