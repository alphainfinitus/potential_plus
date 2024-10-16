import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  const Attendance({
    required this.id,
    required this.userId,
    required this.isPresent,
    required this.institutionId,
    this.classId,
    required this.createdAt,
    required this.updatedAt,
    required this.markedByUserId,
  });

  final String id;
  final String userId;
  final bool isPresent;
  final String institutionId;
  final String? classId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String markedByUserId;

  factory Attendance.fromMap(Map<String, dynamic> data) {
    return Attendance(
      id: data['id'],
      userId: data['userId'],
      isPresent: data['isPresent'],
      institutionId: data['institutionId'],
      classId: data['classId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      markedByUserId: data['markedByUserId'],
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'isPresent': isPresent,
    'institutionId': institutionId,
    'classId': classId,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'markedByUserId': markedByUserId,
  };
}
