import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/activity.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/providers/teacher_activity_provider/teacher_activity_provider.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/utils.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Institution? institution = ref.watch(institutionProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: "Teacher Dashboard"),
      ),
      body: user.when(
        data: (appUser) {
          // Not logged in, redirect to login screen
          if (appUser == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(AppRoutes.login.path);
            });
            return null;
          }

          if (institution == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(context, appUser),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildRecentActivity(context, ref),
                ],
              ),
            ),
          );
        },
        error: (error, _) =>
            const Center(child: Text(TextLiterals.authStatusUnkown)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, AppUser user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.name}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Here\'s what\'s happening today',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _QuickActionCard(
              icon: Icons.check_circle_outline,
              title: 'Mark Attendance',
              color: Colors.blue.shade700,
              onTap: () => context.push(AppRoutes.teacherMarkAttendance.path),
            ),
            _QuickActionCard(
              icon: Icons.calendar_month,
              title: 'View Timetable',
              color: Colors.teal.shade600,
              onTap: () {
                // TODO: Add timetable route when implemented
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Timetable feature coming soon!'),
                  ),
                );
              },
            ),
            _QuickActionCard(
              icon: Icons.assignment,
              title: 'Assignments',
              color: Colors.purple.shade600,
              onTap: () {
                // TODO: Add assignments route when implemented
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Assignments feature coming soon!'),
                  ),
                );
              },
            ),
            _QuickActionCard(
              icon: Icons.analytics,
              title: 'Performance',
              color: Colors.orange.shade600,
              onTap: () {
                // TODO: Add performance route when implemented
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Performance analytics coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(teacherActivitiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        activitiesAsync.when(
          data: (activities) {
            if (activities.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No recent activities',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ),
                ),
              );
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    for (var i = 0; i < activities.length; i++)
                      Column(
                        children: [
                          _ActivityItem(
                            icon: _getActivityIcon(activities[i].type),
                            title: activities[i].title,
                            subtitle: activities[i].description,
                            time:
                                AppUtils.formatTimeAgo(activities[i].timestamp),
                          ),
                          if (i < activities.length - 1) const Divider(),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Error loading activities: $error',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'attendance':
        return Icons.check_circle;
      case 'assignment':
        return Icons.assignment;
      case 'timetable':
        return Icons.calendar_today;
      case 'exam':
        return Icons.quiz;
      case 'announcement':
        return Icons.announcement;
      default:
        return Icons.event;
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                    ),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
