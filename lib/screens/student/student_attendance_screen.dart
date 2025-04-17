import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/utils.dart';

// Providers
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedDayProvider = StateProvider<DateTime?>((ref) => null);
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

final sortedAttendanceDataProvider =
    Provider<Map<DateTime, List<Attendance>>>((ref) {
  final attendanceData = ref.watch(studentAttendanceProvider);
  return attendanceData.when(
    data: (data) {
      final Map<DateTime, List<Attendance>> sortedData = {};
      data.forEach((date, attendances) {
        for (var attendance in attendances) {
          final createdAtDate = DateTime(
            attendance.createdAt.year,
            attendance.createdAt.month,
            attendance.createdAt.day,
          );
          sortedData.putIfAbsent(createdAtDate, () => []).add(attendance);
        }
      });
      return sortedData;
    },
    error: (_, __) => {},
    loading: () => {},
  );
});

// Widgets
class StudentAttendanceScreen extends ConsumerWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: 'Attendance'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
      ),
      body: _buildBody(context, ref),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    return user.when(
      data: (appUser) => _buildUserContent(context, ref, appUser),
      error: (error, stackTrace) => _buildErrorView(context, error, stackTrace),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildUserContent(
      BuildContext context, WidgetRef ref, AppUser? appUser) {
    if (appUser == null || appUser.classId == null) {
      return _buildNoClassView(context);
    }

    final classes = ref.watch(classesProvider).value;
    if (classes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final studentClass = classes[appUser.classId];
    if (studentClass == null) {
      return _buildClassNotFoundView(context);
    }

    return _buildAttendanceView(context, ref);
  }

  Widget _buildAttendanceView(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    return Column(
      children: [
        _buildCalendar(context, ref),
        if (selectedDay != null)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildAttendanceStats(context, ref, selectedDay),
                  _buildDayDetails(context, ref, selectedDay),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(focusedDayProvider);
    final sortedAttendanceData = ref.watch(sortedAttendanceDataProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          defaultTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Theme.of(context).colorScheme.primary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          ref.read(selectedDayProvider.notifier).state = selectedDay;
          ref.read(focusedDayProvider.notifier).state = focusedDay;
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final dateKey = DateTime(day.year, day.month, day.day);
            final attendances = sortedAttendanceData[dateKey] ?? [];
            final hasAttendance = attendances.isNotEmpty;
            final isPresent = attendances.any((a) => a.isPresent);

            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: hasAttendance
                    ? (isPresent
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3))
                    : null,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: hasAttendance
                        ? (isPresent
                            ? Colors.green.shade900
                            : Colors.red.shade900)
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight:
                        hasAttendance ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttendanceStats(
      BuildContext context, WidgetRef ref, DateTime selectedDay) {
    final sortedAttendanceData = ref.watch(sortedAttendanceDataProvider);
    final stats = _calculateAttendanceStats(sortedAttendanceData, selectedDay);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Attendance Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(context, 'Present', stats.present, Colors.green),
              const SizedBox(width: 24),
              _buildLegendItem(context, 'Absent', stats.absent, Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Center(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: stats.presentPercentage,
                      title: '${stats.presentPercentage.toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: stats.absentPercentage,
                      title: '${stats.absentPercentage.toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDetails(
      BuildContext context, WidgetRef ref, DateTime selectedDay) {
    final sortedAttendanceData = ref.watch(sortedAttendanceDataProvider);
    final attendances = _getDayAttendances(sortedAttendanceData, selectedDay);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppUtils.formatDate(selectedDay),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (attendances.isEmpty)
            Center(
              child: Text(
                'No attendance records for this day',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          else
            ...attendances.map(
                (attendance) => _buildAttendanceRecord(context, attendance)),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildNoClassView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
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

  Widget _buildClassNotFoundView(BuildContext context) {
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

  Widget _buildErrorView(
      BuildContext context, Object error, StackTrace stackTrace) {
    log('Error loading user data:');
    log('Error: $error');
    log('Stack trace: $stackTrace');
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
            'Error loading attendance',
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      BuildContext context, String label, int value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 8),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildAttendanceRecord(BuildContext context, Attendance attendance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: attendance.isPresent ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${attendance.isPresent ? 'Present' : 'Absent'} - ${AppUtils.formatTime(attendance.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  AttendanceStats _calculateAttendanceStats(
      Map<DateTime, List<Attendance>> data, DateTime selectedDay) {
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalAttendance = 0;

    data.forEach((date, records) {
      if (date.month == selectedDay.month && date.year == selectedDay.year) {
        final presentCount = records.where((a) => a.isPresent).length;
        final absentCount = records.where((a) => !a.isPresent).length;
        totalPresent += presentCount;
        totalAbsent += absentCount;
        totalAttendance += records.length;
      }
    });

    final presentPercentage = totalAttendance > 0
        ? (totalPresent / totalAttendance * 100).toDouble()
        : 0.0;
    final absentPercentage = totalAttendance > 0
        ? (totalAbsent / totalAttendance * 100).toDouble()
        : 0.0;

    return AttendanceStats(
      present: totalPresent,
      absent: totalAbsent,
      presentPercentage: presentPercentage,
      absentPercentage: absentPercentage,
    );
  }

  List<Attendance> _getDayAttendances(
      Map<DateTime, List<Attendance>> data, DateTime selectedDay) {
    return data.entries
        .where((entry) {
          final entryDate = entry.key;
          return entryDate.year == selectedDay.year &&
              entryDate.month == selectedDay.month &&
              entryDate.day == selectedDay.day;
        })
        .expand((entry) => entry.value)
        .toList();
  }
}

// Data Classes
class AttendanceStats {
  final int present;
  final int absent;
  final double presentPercentage;
  final double absentPercentage;

  AttendanceStats({
    required this.present,
    required this.absent,
    required this.presentPercentage,
    required this.absentPercentage,
  });
}
