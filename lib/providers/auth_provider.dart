import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/services/db_service.dart';

final authProvider = StreamProvider.autoDispose<AppUser?>((ref) async* {
  final Stream<AppUser?> appUserStream = FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) {
      return null;
    }

    // fetch user data from db
    final appUser = await DbService.fetchUserData(user.uid);

    if (appUser == null) {
      return null;
    }

    return appUser;
  });

  await for (final AppUser? appUser in appUserStream) {
    yield appUser;
  }
});