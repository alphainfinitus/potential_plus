import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';

final authProvider = StreamProvider.autoDispose<AppUser?>((ref) async* {
  final Stream<AppUser?> userStream = FirebaseAuth.instance.authStateChanges().map((user) {
    if (user == null) {
      return null;
    }

    // fetch additional user data from firestore

    return AppUser(
      id: user.uid,
      email: user.email!,
    );
  });

  await for (final AppUser? user in userStream) {
    yield user;
  }
});