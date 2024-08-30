import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/providers/auth_provider.dart';
import 'package:potential_plus/services/db_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'institution_provider.g.dart';

@riverpod
Future<Institution?> institution(InstitutionRef ref) async {
  final AppUser? appUser = ref.watch(authProvider).value;

  if (appUser == null) {
    return null;
  }

  // fetch institution data from db
  final institutionData = await DbService.fetchInstitutionData(appUser.institutionId);

  return institutionData;
}