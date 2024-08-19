import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/constants/user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.username, //typically UID given by institution to the student/teacher, (assigned by us in case of admin role)
    required this.name,
    required this.email,
    required this.role
  });

  final String id;
  final String username;
  final String name;
  final String email;
  final UserRole role;


  factory AppUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options
    ) {
    final data = snapshot.data()!;

    UserRole role = UserRole.values.byName(data['role']);

    return AppUser(
      id: data['id'],
      username: data['username'],
      name: data['name'],
      email: data['email'],
      role: role,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'name': name,
    'email': email,
    'role': role.toString(),
  };
}