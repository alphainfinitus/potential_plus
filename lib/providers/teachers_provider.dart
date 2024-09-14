import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/auth_provider.dart';
import 'package:potential_plus/services/db_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'teachers_provider.g.dart';

// returns a map with key of teacherId and value of AppUser 
@riverpod
Future<Map<String, AppUser>?> teachers(TeachersRef ref) async {
  final AppUser? appUser = ref.watch(authProvider).value;

  // no need to fetch all teachers if user is not an admin
  if (appUser == null || (appUser.role != UserRole.admin && appUser.role != UserRole.teacher)) return null;


  // fetch institution's classes from db
  return await DbService.fetchTeachersForInstitution(appUser.institutionId);
}