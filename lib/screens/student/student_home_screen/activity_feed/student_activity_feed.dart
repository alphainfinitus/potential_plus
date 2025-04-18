import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/student_activity_provider/student_activity_provider.dart';
import 'package:potential_plus/models/activity.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:intl/intl.dart';
import 'package:potential_plus/constants/responsive.dart';

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
        await ref.refresh(studentActivityNotifierProvider.future);
      },
      child: activitiesStream.when(
          data: (activities) {
            if (activities == null || activities.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_note,
                      size: Responsive.getFontSize(context, 48),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5),
                    ),
                    SizedBox(
                        height: Responsive.getMargin(
                            context, ResponsiveSizes.marginMedium)),
                    Text(
                      'No activities found',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 16),
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.symmetric(
                vertical: Responsive.getPadding(
                    context, ResponsiveSizes.paddingMedium),
                horizontal: Responsive.getPadding(
                    context, ResponsiveSizes.paddingMedium),
              ),
              itemCount: activities.length,
              separatorBuilder: (context, index) => Divider(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                height:
                    Responsive.getMargin(context, ResponsiveSizes.marginMedium),
              ),
              itemBuilder: (context, index) {
                if (index == activities.length - 1) {
                  // Load more when reaching the end
                  ref
                      .read(studentActivityNotifierProvider.notifier)
                      .loadMoreActivities(activities[index]);
                }
                return _buildActivityDetailTile(activities[index]);
              },
            );
          },
          loading: () => Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          error: (error, stack) {
            log(error.toString());
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: Responsive.getFontSize(context, 48),
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(
                      height: Responsive.getMargin(
                          context, ResponsiveSizes.marginMedium)),
                  Text(
                    'Error loading activities',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 16),
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildActivityDetailTile(Activity activity) {
    return FutureBuilder<Attendance>(
      future: ref
          .read(studentActivityNotifierProvider.notifier)
          .fetchActivityDetails(activity.id, activity.type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical:
                  Responsive.getPadding(context, ResponsiveSizes.paddingSmall),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(
                    width: Responsive.getMargin(
                        context, ResponsiveSizes.marginMedium)),
                Text(
                  'Loading activity details...',
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 14),
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical:
                  Responsive.getPadding(context, ResponsiveSizes.paddingSmall),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: Responsive.getFontSize(context, 24),
                ),
                SizedBox(
                    width: Responsive.getMargin(
                        context, ResponsiveSizes.marginMedium)),
                Text(
                  'Error loading details',
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 14),
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          );
        }

        final attendance = snapshot.data!;
        final formattedDate =
            DateFormat('EEE, MMM dd, h:mm a').format(activity.timestamp);
        final isPresent = attendance.isPresent;

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical:
                Responsive.getPadding(context, ResponsiveSizes.paddingSmall),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.getPadding(
                        context, ResponsiveSizes.paddingSmall)),
                    decoration: BoxDecoration(
                      color: isPresent
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Responsive.getRadius(
                          context, ResponsiveSizes.radiusMedium)),
                    ),
                    child: Icon(
                      isPresent ? Icons.check_circle : Icons.cancel,
                      color: isPresent ? Colors.green : Colors.red,
                      size: Responsive.getFontSize(context, 20),
                    ),
                  ),
                  SizedBox(
                      width: Responsive.getMargin(
                          context, ResponsiveSizes.marginMedium)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance Status',
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(
                            height: Responsive.getMargin(
                                context, ResponsiveSizes.marginSmall)),
                        Text(
                          '${widget.appUser.name} was ${isPresent ? 'present' : 'absent'} for the class',
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(context, 14),
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: Responsive.getMargin(
                      context, ResponsiveSizes.marginSmall)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Class ID: ${attendance.classId}',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 14),
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 14),
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
