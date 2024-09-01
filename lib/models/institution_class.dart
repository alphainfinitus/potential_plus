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
    required this.name,
    required this.timeTable,
  });

  final String id;
  final String name;

  // {
  //   0 (dayOfWeek): [
  //     {subject: 'subject1', teacherId: 'teacherID1'},
  //     {subject: 'subject2', teacherId: 'teacherID2'}
  //   ]
  // }
  final Map<String, List<TimetableEntry>> timeTable;

  factory InstitutionClass.fromMap(Map<String, dynamic> data) {
    Map<String, List<TimetableEntry>> timeTable = {};

    data['timeTable'].forEach((key, value) {
      timeTable[key] = List<TimetableEntry>.from(
        value.map<TimetableEntry>((e) => TimetableEntry.fromMap(Map<String, String>.from(e)))
      );
    });

    return InstitutionClass(
      id: data['id'],
      name: data['name'],
      timeTable: timeTable,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'timeTable': timeTable.map((key, value) => MapEntry(key, value.map((e) => e.toMap()).toList())),
  };
}