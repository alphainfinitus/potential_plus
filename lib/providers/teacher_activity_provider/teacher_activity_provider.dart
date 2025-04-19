import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/activity/activity.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/services/db_service.dart';

final teacherActivitiesProvider = StreamProvider<List<Activity>>((ref) {
  final user = ref.watch(authProvider).value;
  if (user == null) return Stream.value([]);

  return DbService.activitiesCollRef()
      .where('userId', isEqualTo: user.id)
      .orderBy('createdAt', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  });
});
