import 'package:firebase_auth/firebase_auth.dart';
import 'package:potential_plus/services/fcm_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return null;
      }

      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  static Future<void> signOut() async {
    await FCMService.removeToken();
    await _auth.signOut();
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
