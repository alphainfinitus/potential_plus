import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';

class DbService {
  static final db = FirebaseFirestore.instance;

  //refs
  static CollectionReference<AppUser> usersCollRef() => db
    .collection('users')
    .withConverter(
      fromFirestore: (snapshot, _) => AppUser.fromMap(snapshot.data()!),
      toFirestore: (AppUser user, _) => user.toMap(),
    );

  static CollectionReference<Institution> institutionsCollRef() => db
    .collection('institutions')
    .withConverter(
      fromFirestore: (snapshot, _) => Institution.fromMap(snapshot.data()!),
      toFirestore: (Institution user, _) => user.toMap(),
    );

  static CollectionReference<InstitutionClass> institutionClassesCollRef(String institutionId) => db
    .collection('institutions')
    .doc(institutionId)
    .collection('classes')
    .withConverter(
      fromFirestore: (snapshot, _) => InstitutionClass.fromMap(snapshot.data()!),
      toFirestore: (InstitutionClass institutionClass, _) => institutionClass.toMap(),
    );

  // Methods
  static Future<AppUser?> fetchUserData(String userId) async {
    final userDoc = await usersCollRef().doc(userId).get();
    return userDoc.data();
  }

  static Future<Institution?> fetchInstitutionData(String institutionId) async {
    final institutionDoc = await institutionsCollRef().doc(institutionId).get();
    return institutionDoc.data();
  }

  // returns a map with key of institutionClassId and value of InstitutionClass
  static Future<Map<String, InstitutionClass>> fetchClassesForInstitution(String institutionId) async {
    final institutionClassesSnapshot = await institutionClassesCollRef(institutionId).get();
    return institutionClassesSnapshot.docs.fold<Map<String, InstitutionClass>>(
      {},
      (acc, doc) => acc..[doc.id] = doc.data(),
    );
  }
    
}