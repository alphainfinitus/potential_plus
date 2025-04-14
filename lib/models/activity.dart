import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String teacherId;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.teacherId,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      teacherId: data['teacherId'] ?? '',
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  factory Activity.fromMap(Map<String, dynamic> data) {
    return Activity(
      id: data['id'] ?? '',
      teacherId: data['teacherId'] ?? '',
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'type': type,
      'title': title,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
