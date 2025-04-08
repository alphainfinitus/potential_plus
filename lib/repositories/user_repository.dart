import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    // Check if user with email already exists
    try {
      final existingUsers = await DbService.usersCollRef()
          .where('email', isEqualTo: email)
          .get();

      if (existingUsers.docs.isNotEmpty) {
        throw Exception('A user with this email already exists');
      }

      // Create Firebase Auth user with username as password
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: username, // Using username as default password
      );

      final userId = userCredential.user!.uid;
      final newUserDoc = DbService.usersCollRef().doc(userId);
      final now = DateTime.now();

      final newUser = AppUser(
        id: userId,
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
      return userId;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('A user with this email already exists');
      }
      rethrow;
    }
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
