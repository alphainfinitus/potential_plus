import 'package:potential_plus/constants/activity_type.dart';
import 'package:potential_plus/models/activity/activity.dart';
import 'package:potential_plus/models/attendance/attendance.dart';
import 'package:potential_plus/services/db_service.dart';
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
    return DbService.fetchUserActivitiesStreamWithLimit(appUser.id);
  }

  Future<void> loadMoreActivities(Activity lastActivity) async {
    final appUser = ref.read(authProvider).value;
    if (appUser == null || appUser.role != UserRole.student) {
      return;
    }
    final nextActivities = await DbService.fetchUserActivitiesBeforeDate(appUser.id, lastActivity.createdAt);

    state = AsyncValue.data([
      ...state.value ?? [],
      ...nextActivities,
    ]);
  }

  // fetch activity details
  Future<Attendance> fetchActivityDetails(String activityId, ActivityType activityType) async {
    return await DbService.fetchActivityDetails(activityId, activityType);
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
    return DbService.fetchUserActivitiesStreamWithLimit(appUser.id);
  }
}
