import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/student_activity_provider/student_activity_provider.dart';
import 'package:potential_plus/models/activity.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/constants/activity_type.dart';
import 'package:intl/intl.dart';

class StudentActivityFeed extends ConsumerStatefulWidget {
  const StudentActivityFeed({super.key, required this.appUser});

  final AppUser appUser;

  @override
  ConsumerState<StudentActivityFeed> createState() =>
      _StudentActivityFeedState();
}

class _StudentActivityFeedState extends ConsumerState<StudentActivityFeed> {
  @override
  Widget build(BuildContext context) {
    final activitiesStream = ref.watch(studentActivityNotifierProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(studentActivityNotifierProvider);
      },
      child: activitiesStream.when(
        data: (activities) {
          if (activities == null || activities.isEmpty) {
            return const Center(child: Text('No activities found'));
          }

          // Limit to top 10 most recent activities
          final recentActivities = activities.take(10).toList();

          return ListView.builder(
            itemCount: recentActivities.length,
            itemBuilder: (context, index) {
              final activity = recentActivities[index];
              return _buildActivityTile(activity);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildActivityTile(Activity activity) {
    // Activity timestamp
    final activityTimestamp =
        DateFormat('EEE dd, h:mm a').format(activity.createdAt);

    // For attendance activities, we need to fetch additional details
    if (activity.activityType == ActivityType.attendance) {
      return _buildAttendanceActivityTile(activity, activityTimestamp);
    }

    // For all other activity types, just show the message
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  activity.activityType == ActivityType.announcement
                      ? Icons.campaign
                      : Icons.notifications,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  activity.title ?? activity.activityType.name.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const Spacer(),
                Text(
                  activityTimestamp,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (activity.message != null && activity.message!.isNotEmpty)
              Text(
                activity.message!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceActivityTile(
      Activity activity, String activityTimestamp) {
    return FutureBuilder<Attendance>(
      future: ref
          .read(studentActivityNotifierProvider.notifier)
          .fetchActivityDetails(activity.activityRefId, activity.activityType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Loading...', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text('Error: ${snapshot.error}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        }

        final attendance = snapshot.data!;

        // Format date for display
        final attendanceDate = attendance.dateTime;
        final formattedAttendanceDate =
            DateFormat('dd MMM').format(attendanceDate);

        // Get the lecture name from metadata
        final lectureName = attendance.metaData?.subject ?? 'Unknown Lecture';

        // Attendance status
        final status = attendance.isPresent ? 'present' : 'absent';

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.how_to_reg,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ATTENDANCE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.green,
                            fontSize: 10,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      activityTimestamp,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  activity.message!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
