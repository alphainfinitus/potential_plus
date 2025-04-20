import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/services/db_service.dart';

class InstitutionRepository {
  static Future<Institution?> fetchInstitutionData(String institutionId) async {
    final institutionDoc = await DbService.institutionsCollRef().doc(institutionId).get();
    return institutionDoc.data();
  }

  // returns a map with key of institutionClassId and value of InstitutionClass
  static Future<Map<String, InstitutionClass>> fetchClassesForInstitution(String institutionId) async {
    final institutionClassesSnapshot = await DbService.classesCollRef().where('institutionId', isEqualTo: institutionId).get();
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

  static Future updateClassPeriodDetails({
    required String institutionId,
    required String institutionClassId,
    required Map<String, List<TimetableEntry>> newTimeTable,
  }) async {

  }
}