import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/shared/logout_button.dart';
import 'package:potential_plus/providers/student_activity_provider.dart';
import 'package:potential_plus/models/activity.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:intl/intl.dart';

class StudentActivityFeed extends ConsumerStatefulWidget {
  const StudentActivityFeed({super.key, required this.appUser });

  final AppUser appUser;

  @override
  ConsumerState<StudentActivityFeed> createState() => _StudentActivityFeedState();
}

class _StudentActivityFeedState extends ConsumerState<StudentActivityFeed> {
  @override
  Widget build(BuildContext context) {
    final activitiesStream = ref.watch(studentActivityNotifierProvider);

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh the activities
        ref.refresh(studentActivityNotifierProvider);
      },
      child: activitiesStream.when(
        data: (activities) {
          if (activities == null || activities.isEmpty) {
            return const Center(child: Text('No activities found'));
          }
          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return _buildActivityDetailTile(activities[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildActivityDetailTile(Activity activity) {
    return FutureBuilder<Attendance>(
      future: ref.read(studentActivityNotifierProvider.notifier)
          .fetchActivityDetails(activity.activityRefId, activity.activityType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Loading...'),
            leading: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return ListTile(
            title: Text('Error: ${snapshot.error}'),
            leading: const Icon(Icons.error),
          );
        }
        final attendance = snapshot.data!;
        final formattedDate = DateFormat('EEE dd, h:mm a').format(activity.createdAt);
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                Text("Your ward is ${attendance.isPresent ? 'present' : 'absent'}", style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ),
        );
      },
    );
  }
}