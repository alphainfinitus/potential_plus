import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/models/app_user.dart';

class DbService {
  static final db = FirebaseFirestore.instance;

  //refs
  static final usersCollRef = db
    .collection('users')
    .withConverter(
      fromFirestore: (snapshot, _) => AppUser.fromMap(snapshot.data()!),
      toFirestore: (AppUser user, _) => user.toMap(),
    );

  static Future<AppUser?> fetchUserData(String userId) async {
    final userDoc = await usersCollRef.doc(userId).get();
    return userDoc.data();
  }
    
}