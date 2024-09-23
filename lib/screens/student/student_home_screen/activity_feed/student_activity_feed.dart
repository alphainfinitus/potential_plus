import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/shared/logout_button.dart';
import 'package:potential_plus/providers/student_activity_provider.dart';
import 'package:potential_plus/models/activity.dart';
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
            itemCount: activities.length + 1, // +1 for the logout button
            itemBuilder: (context, index) {
              if (index == activities.length) {
                return const Column(
                  children: [
                    SizedBox(height: 16.0),
                    LogoutButton(),
                    SizedBox(height: 16.0),
                  ],
                );
              }
              final activity = activities[index];
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
    final formattedDate = DateFormat('EEE, h:mm a').format(activity.createdAt);
    return ListTile(
      minVerticalPadding: 16.0,
      title: Text(activity.activityType.name),
      subtitle: Text(activity.activityRefId),
      leading: Text(formattedDate),
    );
  }
}