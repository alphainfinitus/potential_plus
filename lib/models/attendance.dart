import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  const Attendance({
    required this.forDate,
    required this.id,
    required this.userId,
    required this.isPresent,
    required this.institutionId,
    this.classId,
    required this.createdAt,
    required this.updatedAt,
    required this.markedByUserId,
    this.metaData,
  });

  final String id;
  final DateTime forDate;
  final String userId;
  final bool isPresent;
  final String institutionId;
  final String? classId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String markedByUserId;
  final MetaData? metaData;

  factory Attendance.fromMap(Map<String, dynamic> data) {
    return Attendance(
      id: data['id'],
      forDate: (data['forDate'] as Timestamp).toDate(),
      userId: data['userId'],
      isPresent: data['isPresent'],
      institutionId: data['institutionId'],
      classId: data['classId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      markedByUserId: data['markedByUserId'],
      metaData:
          data['metaData'] != null ? MetaData.fromMap(data['metaData']) : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'forDate': Timestamp.fromDate(forDate),
        'userId': userId,
        'isPresent': isPresent,
        'institutionId': institutionId,
        'classId': classId,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'markedByUserId': markedByUserId,
        'metaData': metaData?.toMap(),
      };
}

class MetaData {
  const MetaData({
    required this.subject,
    required this.timeTableId,
    required this.timeTableEntryId,
  });

  final String subject;
  final String timeTableId;
  final String timeTableEntryId;

  factory MetaData.fromMap(Map<String, dynamic> data) {
    return MetaData(
      subject: data['subject'],
      timeTableId: data['timeTableId'],
      timeTableEntryId: data['timeTableEntryId'],
    );
  }

  Map<String, dynamic> toMap() => {
        'subject': subject,
        'timeTableId': timeTableId,
        'timeTableEntryId': timeTableEntryId,
      };
}
