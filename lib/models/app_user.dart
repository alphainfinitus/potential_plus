import 'package:potential_plus/constants/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.username, //typically UID given by institution to the student/teacher, (assigned by us in case of admin role)
    required this.name,
    required this.email,
    required this.role,
    required this.institutionId,
    this.classId,
    required this.createdAt,
    required this.updatedAt,
    this.fcmToken,
  });

  final String id;
  final String username;
  final String name;
  final String email;
  final UserRole role;
  final String institutionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? classId;
  final String? fcmToken;

  factory AppUser.fromMap(Map<String, dynamic> data) {
    UserRole role = UserRole.values.byName(data['role']);

    return AppUser(
      id: data['id'],
      username: data['username'],
      name: data['name'],
      email: data['email'],
      role: role,
      institutionId: data['institutionId'],
      classId: data['classId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'name': name,
        'email': email,
        'role': role.name,
        'institutionId': institutionId,
        'classId': classId,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'fcmToken': fcmToken,
      };
}
