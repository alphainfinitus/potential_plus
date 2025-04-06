import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/repositories/user_repository.dart';

// Manual providers
final institutionStudentsProvider =
    AutoDisposeFutureProvider<Map<String, AppUser>>((ref) async {
  final AppUser? appUser = ref.watch(authProvider).value;

  if (appUser == null) return {};

  return await UserRepository.fetchAllStudentsForInstitution(
      appUser.institutionId);
});

final institutionTeachersProvider =
    AutoDisposeFutureProvider<Map<String, AppUser>>((ref) async {
  final AppUser? appUser = ref.watch(authProvider).value;

  if (appUser == null) return {};

  return await UserRepository.fetchAllTeachersForInstitution(
      appUser.institutionId);
});
