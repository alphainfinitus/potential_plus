import 'package:potential_plus/constants/activity_type.dart';
import 'package:potential_plus/models/activity.dart';
import 'package:potential_plus/repositories/student_repository.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/constants/user_role.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'student_activity_provider.g.dart';

@riverpod
class StudentActivityNotifier extends _$StudentActivityNotifier {
  @override
  Stream<List<Activity>?> build() {
    final appUser = ref.watch(authProvider).value;
    if (appUser == null || appUser.role != UserRole.student) {
      return Stream.value(null);
    }
    return StudentRepository.fetchUserActivitiesStreamWithLimit(appUser.id);
  }

  Future<void> loadMoreActivities(Activity lastActivity) async {
    final appUser = ref.read(authProvider).value;
    if (appUser == null || appUser.role != UserRole.student) {
      return;
    }
    final nextActivities =
        await StudentRepository.fetchUserActivitiesBeforeDate(
            appUser.id, lastActivity.timestamp);

    state = AsyncValue.data([
      ...state.value ?? [],
      ...nextActivities,
    ]);
  }

  // fetch activity details
  Future<Attendance> fetchActivityDetails(
      String activityId, String type) async {
    return await StudentRepository.fetchActivityDetails(activityId, type);
  }
}

@riverpod
class LiveStudentActivityNotifier extends _$LiveStudentActivityNotifier {
  @override
  Stream<List<Activity>?> build() {
    final appUser = ref.watch(authProvider).value;
    if (appUser == null || appUser.role != UserRole.student) {
      return Stream.value(null);
    }
    return StudentRepository.fetchUserActivitiesStream(appUser.id);
  }
}
