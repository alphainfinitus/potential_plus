import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/activity.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';

final teacherActivitiesProvider = StreamProvider<List<Activity>>((ref) {
  final user = ref.watch(authProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('activities')
      .where('teacherId', isEqualTo: user.id)
      .orderBy('timestamp', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
  });
});
