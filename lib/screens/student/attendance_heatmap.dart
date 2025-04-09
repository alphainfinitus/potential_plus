import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';
import 'package:potential_plus/constants/responsive.dart';
import 'package:potential_plus/models/attendance.dart';

class AttendanceHeatmap extends StatefulWidget {
  final Map<DateTime, List<Attendance>> attendanceData;

  const AttendanceHeatmap({
    super.key,
    required this.attendanceData,
  });

  @override
  State<AttendanceHeatmap> createState() => _AttendanceHeatmapState();
}

class _AttendanceHeatmapState extends State<AttendanceHeatmap> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    // Initialize with the current month
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attendance Heatmap',
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildMonthCalendar(context, _selectedMonth),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCalendar(BuildContext context, DateTime month) {
    final Map<DateTime, int> heatmapDatasets = {};

    // Convert attendance data to heatmap format
    widget.attendanceData.forEach((date, attendances) {
      for (var attendance in attendances) {
        final dayDate = DateTime(
          attendance.createdAt.year,
          attendance.createdAt.month,
          attendance.createdAt.day,
        );

        heatmapDatasets[dayDate] = attendance.isPresent ? 1 : -1;
      }
    });

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.getPadding(context, ResponsiveSizes.paddingSmall),
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.3),
        borderRadius: BorderRadius.circular(
            Responsive.getRadius(context, ResponsiveSizes.radiusMedium)),
      ),
      child: HeatMapCalendar(
        defaultColor: Colors.grey.shade300,
        flexible: true,
        colorMode: ColorMode.color,
        datasets: heatmapDatasets,
        colorsets: {
          1: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          -1: Theme.of(context).colorScheme.error.withOpacity(0.7),
          0: Colors.grey.shade300,
        },
        weekFontSize: 12.0,
        weekTextColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        textColor: Theme.of(context).colorScheme.onSurface,
        showColorTip: false,
        onClick: (dateTime) {
          _showDayDetailsDialog(context, dateTime);
        },
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          context,
          'Present',
          Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          context,
          'Absent',
          Theme.of(context).colorScheme.error.withOpacity(0.7),
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          context,
          'No Class',
          Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.getFontSize(context, 12),
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _showDayDetailsDialog(BuildContext context, DateTime date) {
    // Find attendance for this date
    final dateAttendances = widget.attendanceData.entries
        .where((entry) =>
            entry.key.year == date.year && entry.key.month == date.month)
        .expand((entry) => entry.value)
        .where((attendance) =>
            attendance.createdAt.year == date.year &&
            attendance.createdAt.month == date.month &&
            attendance.createdAt.day == date.day)
        .toList();

    final hasAttendance = dateAttendances.isNotEmpty;
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(date);

    String status;
    Color statusColor;

    if (!hasAttendance) {
      status = 'No class or not marked';
      statusColor = Colors.grey;
    } else {
      final attendance = dateAttendances.first;
      status = attendance.isPresent ? 'Present' : 'Absent';
      statusColor = attendance.isPresent
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.error;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          formattedDate,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Status: ',
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(context, 16),
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            if (hasAttendance) ...[
              const SizedBox(height: 8),
              Text(
                'Marked by: ${dateAttendances.first.markedByUserId}',
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 14),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Time: ${DateFormat('hh:mm a').format(dateAttendances.first.createdAt)}',
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 14),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
