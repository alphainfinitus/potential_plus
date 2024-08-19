import 'package:firebase_auth/firebase_auth.dart';
import 'package:potential_plus/models/app_user.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<AppUser?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return null;
      }

      return AppUser(
        id: userCredential.user!.uid,
        email: userCredential.user!.email!
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}