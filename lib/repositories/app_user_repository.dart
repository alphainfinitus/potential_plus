import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/services/db_service.dart';

class AppUserRepository {
  static Future<AppUser?> fetchUserData(String userId) async {
    final userDoc = await DbService.usersCollRef().doc(userId).get();
    return userDoc.data();
  }
}