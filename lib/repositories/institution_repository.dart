import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/services/db_service.dart';

class InstitutionRepository {
  static Future<Institution?> fetchInstitutionData(String institutionId) async {
    final institutionDoc = await DbService.institutionsCollRef().doc(institutionId).get();
    return institutionDoc.data();
  }

  // returns a map with key of institutionClassId and value of InstitutionClass
  static Future<Map<String, InstitutionClass>> fetchClassesForInstitution(String institutionId) async {
    final institutionClassesSnapshot = await DbService.institutionClassesCollRef(institutionId).get();
    return institutionClassesSnapshot.docs.fold<Map<String, InstitutionClass>>(
      {},
      (acc, doc) => acc..[doc.id] = doc.data(),
    );
  }

  // returns a map with key of teacherId and value of AppUser
  static Future<Map<String, AppUser>> fetchTeachersForInstitution(String institutionId) async {
    final teachersSnapshot = await DbService.institutionTeachersQueryRef(institutionId).get();
    return teachersSnapshot.docs.fold<Map<String, AppUser>>(
      {},
      (acc, doc) => acc..[doc.id] = doc.data(),
    );
  }

  // returns a map with key of studentId and value of AppUser
  static Future<Map<String, AppUser>> fetchStudentsForInstitution(String institutionId) async {
    final studentsSnapshot = await DbService.institutionStudentsQueryRef(institutionId).get();
    return studentsSnapshot.docs.fold<Map<String, AppUser>>(
      {},
      (acc, doc) => acc..[doc.id] = doc.data(),
    );
  }

  // TODO : convert all functions to use named parameters
  static Future updateClassPeriodDetails({
    required String institutionId,
    required String institutionClassId,
    required Map<String, List<TimetableEntry>> newTimeTable,
  }) async {
    final institutionClassRef = DbService.institutionClassesCollRef(institutionId).doc(institutionClassId);

    // TODO: optimise this to only update the specific period
    await institutionClassRef.update({
      'timeTable': newTimeTable.map(
				(key, value) => MapEntry(key, value.map((e) => e.toMap()).toList())
			),
    });
  }
}