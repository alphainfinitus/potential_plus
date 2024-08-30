import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';

class DbService {
  static final db = FirebaseFirestore.instance;

  //refs
  static final usersCollRef = db
    .collection('users')
    .withConverter(
      fromFirestore: (snapshot, _) => AppUser.fromMap(snapshot.data()!),
      toFirestore: (AppUser user, _) => user.toMap(),
    );

  static final institutionsCollRef = db
    .collection('institutions')
    .withConverter(
      fromFirestore: (snapshot, _) => Institution.fromMap(snapshot.data()!),
      toFirestore: (Institution user, _) => user.toMap(),
    );

  // Methods
  static Future<AppUser?> fetchUserData(String userId) async {
    final userDoc = await usersCollRef.doc(userId).get();
    return userDoc.data();
  }

  static Future<Institution?> fetchInstitutionData(String institutionId) async {
    final institutionDoc = await institutionsCollRef.doc(institutionId).get();
    return institutionDoc.data();
  }
    
}