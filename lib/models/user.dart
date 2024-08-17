import 'package:potential_plus/constants/user_role.dart';

class User {
  const User({
    required this.id,
    required this.username, //typically UID given by institution to the student/teacher, (assigned by us in case of admin role)
    required this.name,
    required this.email,
    required this.password,
    required this.role // role can be 'student', 'teacher' or 'admin'
  });

  final String id;
  final String username;
  final String name;
  final String email;
  final String password;
  final UserRole role;


  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'name': name,
    'email': email,
    'password': password,
    'roles': role,
  };
}