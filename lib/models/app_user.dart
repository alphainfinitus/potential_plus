import 'package:potential_plus/constants/user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.username, //typically UID given by institution to the student/teacher, (assigned by us in case of admin role)
    required this.name,
    required this.email,
    required this.role,
    required this.institutionId
  });

  final String id;
  final String username;
  final String name;
  final String email;
  final UserRole role;
  final String institutionId;


  factory AppUser.fromMap(Map<String, dynamic> data) {
    UserRole role = UserRole.values.byName(data['role']);

    return AppUser(
      id: data['id'],
      username: data['username'],
      name: data['name'],
      email: data['email'],
      role: role,
      institutionId: data['institutionId']
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'name': name,
    'email': email,
    'role': role.toString(),
    'institutionId': institutionId
  };
}