import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/repositories/institution_repository.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'classes_provider.g.dart';

// returns a map with key of institutionClassId and value of InstitutionClass 

@riverpod
Future<Map<String, InstitutionClass>?> classes(ClassesRef ref) async {
  final AppUser? appUser = ref.watch(authProvider).value;

  // no need to fetch all classes if user is not an admin
  if (appUser == null || (appUser.role != UserRole.admin && appUser.role != UserRole.teacher)) return null;


  // fetch institution's classes from db
  return await InstitutionRepository.fetchClassesForInstitution(appUser.institutionId);
}
