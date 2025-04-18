import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/repositories/institution_repository.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'institution_provider.g.dart';

@riverpod
Future<Institution?> institution(Ref ref) async {
  final AppUser? appUser = ref.watch(authProvider).value;

  if (appUser == null) {
    return null;
  }

  // fetch institution data from db
  final institutionData = await InstitutionRepository.fetchInstitutionData(appUser.institutionId);

  return institutionData;
}