import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/models/activity/activity_data.dart';

class AttendanceActivity implements ActivityData {
  final String className;
  final String classId;
  final String teacherName;
  final String teacherId;
  final DateTime date;
  final bool isPresent;

  AttendanceActivity({
    required this.className,
    required this.classId,
    required this.teacherName,
    required this.teacherId,
    required this.date,
    required this.isPresent,
  });

  factory AttendanceActivity.fromMap(Map<String, dynamic> map) {
    return AttendanceActivity(
      className: map['className'],
      classId: map['classId'],
      teacherName: map['teacherName'],
      teacherId: map['teacherId'],
      date: map['date'].toDate(),
      isPresent: map['isPresent'],
    );
  }

  factory AttendanceActivity.fromFirestore(DocumentSnapshot doc) {
    return AttendanceActivity.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'classId': classId,
      'teacherName': teacherName,
      'teacherId': teacherId,
      'date': date,
      'isPresent': isPresent,
    };
  }
}
