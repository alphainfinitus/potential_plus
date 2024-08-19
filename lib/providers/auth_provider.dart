import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/services/db_service.dart';

final authProvider = StreamProvider.autoDispose<AppUser?>((ref) async* {
  final Stream<AppUser?> userStream = FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) {
      return null;
    }

    // fetch user data from db
    final userData = await DbService.fetchUserData(user.uid);

    if (userData == null) {
      return null;
    }

    return AppUser(
      id: user.uid,
      email: user.email!,
      name: userData.name,
      role: userData.role,
      username: userData.username,
    );
  });

  await for (final AppUser? user in userStream) {
    yield user;
  }
});