import 'package:cloud_firestore/cloud_firestore.dart';

class TimetableEntry {
  const TimetableEntry({
    required this.subject,
    required this.teacherId,
  });

  final String subject;
  final String teacherId;

  factory TimetableEntry.fromMap(Map<String, String> map) {
    return TimetableEntry(
      subject: map['subject'] ?? '',
      teacherId: map['teacherId'] ?? '',
    );
  }

  Map<String, String> toMap() => {
        'subject': subject,
        'teacherId': teacherId,
      };
}

class InstitutionClass {
  const InstitutionClass({
    required this.id,
    required this.institutionId,
    required this.name,
    required this.timeTable,
    required this.createdAt,
    required this.updatedAt,
    required this.studentIds,
  });

  final String id;
  final String institutionId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> studentIds;

  // {
  //   0 (dayOfWeek): [
  //     {subject: 'subject1', teacherId: 'teacherID1'}, // 1st period
  //     {subject: 'subject2', teacherId: 'teacherID2'} // 2nd period
  //   ]
  // }
  final Map<String, List<TimetableEntry>> timeTable;

  factory InstitutionClass.fromMap(Map<String, dynamic> data) {
    Map<String, List<TimetableEntry>> timeTable = {};

    data['timeTable'].forEach((key, value) {
      timeTable[key] = List<TimetableEntry>.from(value.map<TimetableEntry>(
          (e) => TimetableEntry.fromMap(Map<String, String>.from(e))));
    });

    return InstitutionClass(
        id: data['id'],
        institutionId: data['institutionId'],
        name: data['name'],
        timeTable: timeTable,
        studentIds: List<String>.from(data['studentIds'] ?? []),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate());
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'institutionId': institutionId,
        'name': name,
        'timeTable': timeTable.map((key, value) =>
            MapEntry(key, value.map((e) => e.toMap()).toList())),
        'studentIds': studentIds,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt)
      };

  // Override the == operator to compare InstitutionClass objects by id
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InstitutionClass &&
        other.id == id &&
        other.institutionId == institutionId;
  }

  // Override hashCode to return a hash based on id
  @override
  int get hashCode => id.hashCode;
}
