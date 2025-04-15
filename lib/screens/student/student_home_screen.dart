import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/route_paths.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/constants/responsive.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/screens/student/student_home_screen/activity_feed/student_activity_feed.dart';
import 'package:potential_plus/shared/app_bar_title.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Institution? institution = ref.watch(institutionProvider).value;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
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

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh the providers
              ref.refresh(authProvider);
              ref.refresh(institutionProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.getPadding(
                      context, ResponsiveSizes.paddingLarge),
                  vertical: Responsive.getPadding(
                      context, ResponsiveSizes.paddingMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: Responsive.getMargin(
                            context, ResponsiveSizes.marginMedium)),
                    Text(
                      'Welcome, ${appUser.name}',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 26),
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Access your academic information',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 16),
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(
                        height: Responsive.getMargin(
                            context, ResponsiveSizes.marginLarge)),
                    _buildQuickActions(context),
                    SizedBox(
                        height: Responsive.getMargin(
                            context, ResponsiveSizes.marginXLarge)),
                    _buildActivityFeed(appUser, context),
                  ],
                ),
              ),
            ),
          );
        },
        error: (error, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(
                Responsive.getPadding(context, ResponsiveSizes.paddingLarge)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: Responsive.getFontSize(context, 48),
                    color: colorScheme.error),
                SizedBox(
                    height: Responsive.getMargin(
                        context, ResponsiveSizes.marginMedium)),
                Text(
                  TextLiterals.authStatusUnkown,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 16),
                    color: colorScheme.error,
                  ),
                ),
                SizedBox(
                    height: Responsive.getMargin(
                        context, ResponsiveSizes.marginLarge)),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.login.path),
                  child: const Text('Return to Login'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              bottom: Responsive.getPadding(
                  context, ResponsiveSizes.paddingMedium)),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
          mainAxisSpacing:
              Responsive.getMargin(context, ResponsiveSizes.marginMedium),
          crossAxisSpacing:
              Responsive.getMargin(context, ResponsiveSizes.marginMedium),
          childAspectRatio: Responsive.isMobile(context) ? 1.3 : 1.5,
          children: [
            _QuickActionCard(
              icon: Icons.check_circle_outline,
              title: 'Attendance',
              color: Colors.blue.shade700,
              onTap: () => context.push(RoutePaths.studentAttendance),
            ),
            _QuickActionCard(
              icon: Icons.bar_chart,
              title: 'Results',
              color: Colors.indigo.shade600,
              onTap: () => context.push(RoutePaths.studentResults),
            ),
            _QuickActionCard(
              icon: Icons.calendar_month,
              title: 'Timetable',
              color: Colors.teal.shade600,
              onTap: () => context.push(RoutePaths.studentTimetable),
            ),
            _QuickActionCard(
              icon: Icons.chat,
              title: 'Feedback',
              color: Colors.purple.shade600,
              onTap: () => context.push(RoutePaths.studentFeedback),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityFeed(AppUser appUser, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
              bottom: Responsive.getPadding(
                  context, ResponsiveSizes.paddingMedium)),
          child: Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 20),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color:
              Theme.of(context).cardColor.withOpacity(isDarkMode ? 0.1 : 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                Responsive.getRadius(context, ResponsiveSizes.radiusLarge)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
                Responsive.getRadius(context, ResponsiveSizes.radiusLarge)),
            child: SizedBox(
              height: Responsive.isMobile(context) ? 300 : 400,
              child: StudentActivityFeed(appUser: appUser),
            ),
          ),
        ),
      ],
    );
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
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            Responsive.getRadius(context, ResponsiveSizes.radiusLarge)),
      ),
      color: isDarkMode ? Color.lerp(Colors.black, color, 0.15) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
            Responsive.getRadius(context, ResponsiveSizes.radiusLarge)),
        child: Padding(
          padding: EdgeInsets.all(
              Responsive.getPadding(context, ResponsiveSizes.paddingMedium)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.getPadding(
                    context, ResponsiveSizes.paddingSmall)),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Responsive.getRadius(
                      context, ResponsiveSizes.radiusMedium)),
                ),
                child: Icon(
                  icon,
                  size: Responsive.getFontSize(context, 30),
                  color: color,
                ),
              ),
              SizedBox(
                  height: Responsive.getMargin(
                      context, ResponsiveSizes.marginSmall)),
              Text(
                title,
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
