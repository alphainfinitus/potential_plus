import 'dart:developer';

import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/repositories/institution_class_repository.dart';
import 'package:potential_plus/repositories/institution_repository.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'classes_provider.g.dart';

// returns a map with key of institutionClassId and value of InstitutionClass

@riverpod
Future<Map<String, InstitutionClass>?> classes(ClassesRef ref) async {
  final AppUser? appUser = ref.watch(authProvider).value;

  log('Classes provider called by user: ${appUser?.email} with role: ${appUser?.role}');

  if (appUser == null) {
    log('User not logged in');
    return null;
  }

  // If user is a student, fetch only their class
  if (appUser.role == UserRole.student) {
    if (appUser.classId == null) {
      log('Student has no class assigned');
      return null;
    }

    log('Fetching student\'s class: ${appUser.classId}');
    final studentClass = await InstitutionRepository.fetchClassesForInstitution(
        appUser.institutionId);
    // Filter to only include the student's class
    final filteredClasses = studentClass.entries
        .where((entry) => entry.key == appUser.classId)
        .fold<Map<String, InstitutionClass>>(
      {},
      (acc, entry) => acc..[entry.key] = entry.value,
    );
    log('Fetched student\'s class: ${filteredClasses[appUser.classId]?.name}');
    return filteredClasses;
  }

  // For admins and teachers, fetch all classes
  if (appUser.role == UserRole.admin || appUser.role == UserRole.teacher) {
    log('Fetching all classes for institution: ${appUser.institutionId}');
    final classes = await InstitutionRepository.fetchClassesForInstitution(
        appUser.institutionId);

    log('Fetched ${classes.length} classes');
    classes.forEach((id, institutionClass) {
      log('Class: ${institutionClass.name} (ID: $id)');
    });

    return classes;
  }

  log('User role not authorized to fetch classes');
  return null;
}

@riverpod
Future<Map<String, AppUser>> classStudents(
    ClassStudentsRef ref, String classId) async {
  log('Fetching students for class: $classId');
  final students =
      await InstitutionClassRepository.fetchClassStudents(classId: classId);
  log('Fetched ${students.length} students for class: $classId');
  return students;
}

// Manually create the provider for students without a class
final studentsWithoutClassProvider =
    AutoDisposeFutureProvider.family<Map<String, AppUser>, String>(
        (ref, institutionId) async {
  log('Fetching students without class for institution: $institutionId');
  final students =
      await InstitutionClassRepository.fetchInstitutionStudentsWithoutClass(
          institutionId: institutionId);
  log('Fetched ${students.length} students without class');
  return students;
});

final selectedClassProvider = StateProvider<InstitutionClass?>((ref) => null);
