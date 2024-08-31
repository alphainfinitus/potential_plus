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
  //     {subject: subject1, teacher: teacherID1},
  //     {subject: subject2, teacher: teacherID2}
  //   ]
  // }
  final Map<String, List<Map<String, String>>> timeTable;

  factory InstitutionClass.fromMap(Map<String, dynamic> data) {
    Map<String, List<Map<String, String>>> timeTable = {};

    data['timeTable'].forEach((key, value) {
      timeTable[key] = List<Map<String, String>>.from(value.map((e) => Map<String, String>.from(e)));
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
    'timeTable': timeTable,
  };
}