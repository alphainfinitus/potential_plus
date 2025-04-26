import 'package:cloud_firestore/cloud_firestore.dart';

class InstitutionClass {
  const InstitutionClass(
      {required this.id,
      required this.institutionId,
      required this.name,
      required this.timeTableId,
      required this.createdAt,
      required this.updatedAt});

  final String id;
  final String institutionId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? timeTableId;

  factory InstitutionClass.fromMap(Map<String, dynamic> data) {
    return InstitutionClass(
        id: data['id'],
        institutionId: data['institutionId'],
        name: data['name'],
        timeTableId: data['timeTable'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate());
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'institutionId': institutionId,
        'name': name,
        'timeTable': timeTableId,
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
