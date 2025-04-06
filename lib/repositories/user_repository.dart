import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/services/db_service.dart';

class UserRepository {
  static Future<String> createStudent({
    required String name,
    required String email,
    required String username,
    required String institutionId,
  }) async {
    return _createUser(
      name: name,
      email: email,
      username: username,
      institutionId: institutionId,
      role: UserRole.student,
    );
  }

  static Future<String> createTeacher({
    required String name,
    required String email,
    required String username,
    required String institutionId,
  }) async {
    return _createUser(
      name: name,
      email: email,
      username: username,
      institutionId: institutionId,
      role: UserRole.teacher,
    );
  }

  static Future<String> _createUser({
    required String name,
    required String email,
    required String username,
    required String institutionId,
    required UserRole role,
  }) async {
    final newUserDoc = DbService.usersCollRef().doc();
    final now = DateTime.now();

    final newUser = AppUser(
      id: newUserDoc.id,
      username: username,
      name: name,
      email: email,
      role: role,
      institutionId: institutionId,
      classId: null, // Will be set when adding to a class
      createdAt: now,
      updatedAt: now,
    );

    await newUserDoc.set(newUser);
    return newUserDoc.id;
  }

  static Future<Map<String, AppUser>> fetchAllStudentsForInstitution(
      String institutionId) async {
    final studentsSnapshot = await DbService.usersCollRef()
        .where('institutionId', isEqualTo: institutionId)
        .where('role', isEqualTo: UserRole.student.name)
        .get();

    return studentsSnapshot.docs.fold<Map<String, AppUser>>(
      {},
      (acc, doc) => acc..[doc.id] = doc.data(),
    );
  }

  static Future<Map<String, AppUser>> fetchAllTeachersForInstitution(
      String institutionId) async {
    final teachersSnapshot = await DbService.usersCollRef()
        .where('institutionId', isEqualTo: institutionId)
        .where('role', isEqualTo: UserRole.teacher.name)
        .get();

    return teachersSnapshot.docs.fold<Map<String, AppUser>>(
      {},
      (acc, doc) => acc..[doc.id] = doc.data(),
    );
  }
}
