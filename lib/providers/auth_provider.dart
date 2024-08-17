import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/models/user.dart';


// mock user object.
const User user = User(
  id: '1',
  username: 'student_1',
  name: 'John Doe',
  email: 'john@doe.com',
  password: 'john123',
  role: UserRole.student,
);

final authProvider = Provider((ref) {
  return user;
});