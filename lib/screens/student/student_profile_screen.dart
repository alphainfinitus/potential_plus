import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/responsive.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/shared/widgets/theme/dark_mode_toggle_button.dart';
import 'package:potential_plus/shared/logout_button.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Map<String, InstitutionClass>? classes =
        ref.watch(classesProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: 'Student Profile'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
      ),
      body: user.when(
        data: (appUser) {
          if (appUser == null) {
            return const Center(child: Text('User not found'));
          }

          final studentClass = appUser.classId != null && classes != null
              ? classes[appUser.classId]
              : null;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(context, appUser),
                _buildClassInfo(context, studentClass),
                _buildQuickActions(context),
                _buildAccountInfo(context, appUser),
                _buildSettings(context),
              ],
            ),
          );
        },
        error: (error, _) => Center(
          child: Text(
            'Error loading profile',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppUser user) {
    return Container(
      padding: EdgeInsets.all(
          Responsive.getPadding(context, ResponsiveSizes.paddingLarge)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
              Responsive.getRadius(context, ResponsiveSizes.radiusLarge)),
          bottomRight: Radius.circular(
              Responsive.getRadius(context, ResponsiveSizes.radiusLarge)),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, 32),
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          SizedBox(
              height:
                  Responsive.getMargin(context, ResponsiveSizes.marginMedium)),
          Text(
            user.name,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 24),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(
              height:
                  Responsive.getMargin(context, ResponsiveSizes.marginSmall)),
          Text(
            user.email,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 16),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassInfo(BuildContext context, InstitutionClass? studentClass) {
    return Padding(
      padding: EdgeInsets.all(
          Responsive.getPadding(context, ResponsiveSizes.paddingLarge)),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              Responsive.getRadius(context, ResponsiveSizes.radiusMedium)),
        ),
        child: Padding(
          padding: EdgeInsets.all(
              Responsive.getPadding(context, ResponsiveSizes.paddingMedium)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Class Information',
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(
                  height: Responsive.getMargin(
                      context, ResponsiveSizes.marginMedium)),
              if (studentClass != null) ...[
                _buildInfoRow(context, 'Class Name', studentClass.name),
                _buildInfoRow(context, 'Class ID', studentClass.id),
                _buildInfoRow(
                    context, 'Institution ID', studentClass.institutionId),
                _buildInfoRow(context, 'Created At',
                    studentClass.createdAt.toString().split(' ')[0]),
              ] else
                Text(
                  'No class assigned',
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 16),
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal:
            Responsive.getPadding(context, ResponsiveSizes.paddingLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(
              height:
                  Responsive.getMargin(context, ResponsiveSizes.marginMedium)),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  Icons.calendar_today,
                  'Timetable',
                  () {
                    context.push(AppRoutes.studentTimetable.path);
                  },
                ),
              ),
              SizedBox(
                  width: Responsive.getMargin(
                      context, ResponsiveSizes.marginMedium)),
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  Icons.check_circle,
                  'Attendance',
                  () {
                    context.push(AppRoutes.studentAttendance.path);
                  },
                ),
              ),
              SizedBox(
                  width: Responsive.getMargin(
                      context, ResponsiveSizes.marginMedium)),
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  Icons.assignment,
                  'Assignments',
                  () {
                    // TODO: Add assignments route when implemented
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Assignments feature coming soon!'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
          Responsive.getRadius(context, ResponsiveSizes.radiusMedium)),
      child: Container(
        padding: EdgeInsets.all(
            Responsive.getPadding(context, ResponsiveSizes.paddingMedium)),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(
              Responsive.getRadius(context, ResponsiveSizes.radiusMedium)),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(
                height:
                    Responsive.getMargin(context, ResponsiveSizes.marginSmall)),
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, 14),
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo(BuildContext context, AppUser user) {
    return Padding(
      padding: EdgeInsets.all(
          Responsive.getPadding(context, ResponsiveSizes.paddingLarge)),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              Responsive.getRadius(context, ResponsiveSizes.radiusMedium)),
        ),
        child: Padding(
          padding: EdgeInsets.all(
              Responsive.getPadding(context, ResponsiveSizes.paddingMedium)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Information',
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(
                  height: Responsive.getMargin(
                      context, ResponsiveSizes.marginMedium)),
              _buildInfoRow(context, 'User ID', user.id),
              _buildInfoRow(
                  context, 'Role', user.role.toString().split('.').last),
              _buildInfoRow(context, 'Username', user.username),
              _buildInfoRow(
                  context, 'Class ID', user.classId ?? 'Not assigned'),
              _buildInfoRow(context, 'Created At',
                  user.createdAt.toString().split(' ')[0]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.getPadding(context, ResponsiveSizes.paddingSmall),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 14),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal:
            Responsive.getPadding(context, ResponsiveSizes.paddingLarge),
        vertical: Responsive.getPadding(context, ResponsiveSizes.paddingMedium),
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              Responsive.getRadius(context, ResponsiveSizes.radiusMedium)),
        ),
        child: Padding(
          padding: EdgeInsets.all(
              Responsive.getPadding(context, ResponsiveSizes.paddingMedium)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(
                  height: Responsive.getMargin(
                      context, ResponsiveSizes.marginMedium)),
              const DarkModeToggleButton(),
              SizedBox(
                  height: Responsive.getMargin(
                      context, ResponsiveSizes.marginMedium)),
              const LogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}
