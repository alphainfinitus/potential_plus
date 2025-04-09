import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/responsive.dart';
import 'package:potential_plus/screens/student/attendance_heatmap.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/attendance.dart';

class StudentAttendanceScreen extends ConsumerWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Map<String, InstitutionClass>? classes =
        ref.watch(classesProvider).value;
    final AsyncValue<Map<DateTime, List<Attendance>>> attendanceData =
        ref.watch(studentAttendanceProvider);
    final AsyncValue<Map<String, int>> stats =
        ref.watch(attendanceStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: 'Attendance'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
      ),
      body: user.when(
        data: (appUser) {
          if (appUser == null || appUser.classId == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.class_outlined,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No class assigned',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }

          if (classes == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final studentClass = classes[appUser.classId];
          if (studentClass == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Class not found',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(
                  Responsive.getPadding(context, ResponsiveSizes.paddingLarge)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, studentClass),
                  SizedBox(
                      height: Responsive.getMargin(
                          context, ResponsiveSizes.marginLarge)),
                  attendanceData.when(
                    data: (attendanceMap) {
                      return AttendanceHeatmap(attendanceData: attendanceMap);
                    },
                    error: (error, _) => Center(
                      child: Text(
                        'Error loading attendance data',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                  ),
                  SizedBox(
                      height: Responsive.getMargin(
                          context, ResponsiveSizes.marginLarge)),
                  _buildAttendanceStats(context, stats),
                ],
              ),
            ),
          );
        },
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading attendance',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, InstitutionClass studentClass) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance Overview',
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 24),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          studentClass.name,
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 16),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // Widget _buildAttendanceHeatmap(BuildContext context,
  //     AsyncValue<Map<DateTime, List<Attendance>>> attendanceData) {
  //   return attendanceData.when(
  //     data: (attendanceMap) {
  //       final now = DateTime.now();
  //       final months = List.generate(6, (index) {
  //         final date = DateTime(now.year, now.month - index, 1);
  //         return DateFormat('MMM yyyy').format(date);
  //       }).reversed.toList();

  //       return Card(
  //         elevation: 2,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(
  //               Responsive.getRadius(context, ResponsiveSizes.radiusLarge)),
  //         ),
  //         child: Padding(
  //           padding: EdgeInsets.all(
  //               Responsive.getPadding(context, ResponsiveSizes.paddingMedium)),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Attendance Heatmap',
  //                 style: TextStyle(
  //                   fontSize: Responsive.getFontSize(context, 18),
  //                   fontWeight: FontWeight.bold,
  //                   color: Theme.of(context).colorScheme.onSurface,
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               SingleChildScrollView(
  //                 scrollDirection: Axis.horizontal,
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       children: months.map((month) {
  //                         return Container(
  //                           width: 200,
  //                           padding: EdgeInsets.symmetric(
  //                               horizontal: Responsive.getPadding(
  //                                   context, ResponsiveSizes.paddingSmall)),
  //                           child: Text(
  //                             month,
  //                             style: TextStyle(
  //                               fontSize: Responsive.getFontSize(context, 12),
  //                               color: Theme.of(context)
  //                                   .colorScheme
  //                                   .onSurface
  //                                   .withOpacity(0.7),
  //                             ),
  //                           ),
  //                         );
  //                       }).toList(),
  //                     ),
  //                     const SizedBox(height: 8),
  //                     Row(
  //                       children: List.generate(6, (monthIndex) {
  //                         final date =
  //                             DateTime(now.year, now.month - monthIndex, 1);
  //                         final monthAttendances = attendanceMap[date] ?? [];

  //                         return Column(
  //                           children: List.generate(31, (dayIndex) {
  //                             final dayDate =
  //                                 DateTime(date.year, date.month, dayIndex + 1);
  //                             if (dayDate.month != date.month) {
  //                               return Container(
  //                                 width: 12,
  //                                 height: 12,
  //                                 margin: EdgeInsets.all(Responsive.getMargin(
  //                                     context, ResponsiveSizes.marginSmall)),
  //                               );
  //                             }

  //                             final dayAttendance = monthAttendances.firstWhere(
  //                               (a) =>
  //                                   a.createdAt.year == dayDate.year &&
  //                                   a.createdAt.month == dayDate.month &&
  //                                   a.createdAt.day == dayDate.day,
  //                               orElse: () => Attendance(
  //                                 id: '',
  //                                 userId: '',
  //                                 isPresent: false,
  //                                 institutionId: '',
  //                                 createdAt: dayDate,
  //                                 updatedAt: dayDate,
  //                                 markedByUserId: '',
  //                               ),
  //                             );

  //                             Color color;
  //                             if (dayAttendance.id.isEmpty) {
  //                               color = Colors.red;
  //                             } else if (dayAttendance.isPresent) {
  //                               color = Theme.of(context)
  //                                   .colorScheme
  //                                   .primary
  //                                   .withOpacity(0.2);
  //                             } else {
  //                               color = Theme.of(context)
  //                                   .colorScheme
  //                                   .error
  //                                   .withOpacity(0.2);
  //                             }

  //                             return Container(
  //                               width: 12,
  //                               height: 12,
  //                               margin: EdgeInsets.all(Responsive.getMargin(
  //                                   context, ResponsiveSizes.marginSmall)),
  //                               decoration: BoxDecoration(
  //                                 color: color,
  //                                 borderRadius: BorderRadius.circular(2),
  //                               ),
  //                             );
  //                           }),
  //                         );
  //                       }),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   _buildLegendItem(context, 'Present',
  //                       Theme.of(context).colorScheme.primary),
  //                   _buildLegendItem(
  //                       context, 'Absent', Theme.of(context).colorScheme.error),
  //                   _buildLegendItem(context, 'No Class',
  //                       Theme.of(context).colorScheme.surface),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //     error: (error, _) => Center(
  //       child: Text(
  //         'Error loading attendance data',
  //         style: TextStyle(
  //           color: Theme.of(context).colorScheme.error,
  //         ),
  //       ),
  //     ),
  //     loading: () => const Center(child: CircularProgressIndicator()),
  //   );
  // }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 12),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceStats(
      BuildContext context, AsyncValue<Map<String, int>> stats) {
    return stats.when(
      data: (stats) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                Responsive.getRadius(context, ResponsiveSizes.radiusLarge)),
          ),
          child: Padding(
            padding: EdgeInsets.all(
                Responsive.getPadding(context, ResponsiveSizes.paddingMedium)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Statistics',
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                    context, 'Total Classes', '${stats['totalClasses']}'),
                _buildStatRow(context, 'Present', '${stats['present']}'),
                _buildStatRow(context, 'Absent', '${stats['absent']}'),
                _buildStatRow(
                    context, 'Attendance %', '${stats['percentage']}%'),
                const SizedBox(height: 16),
                _buildProgressBar(context, stats['percentage']! / 100),
              ],
            ),
          ),
        );
      },
      error: (error, _) => Center(
        child: Text(
          'Error loading attendance stats',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical:
              Responsive.getPadding(context, ResponsiveSizes.paddingSmall)),
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
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double percentage) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
