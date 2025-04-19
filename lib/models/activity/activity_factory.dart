import 'package:potential_plus/constants/activity_type.dart';
import 'package:potential_plus/models/activity/activity_data.dart';
import 'package:potential_plus/models/activity/attendance_activity.dart';

final Map<ActivityType, ActivityData Function(Map<String, dynamic>)> activityDataFactories = {
  ActivityType.attendance: (json) => AttendanceActivity.fromMap(json),
};
