import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_controller.dart';

class StudentAttendanceScreen extends ConsumerWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceControllerProvider);
    final controller = ref.read(attendanceControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('My Attendance'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(16),
                    color: theme.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TableCalendar(
                        firstDay: state.firstDay,
                        lastDay: state.lastDay,
                        focusedDay: state.focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(state.selectedDay, day),
                        calendarFormat: CalendarFormat.month,
                        eventLoader: controller.getEventsForDay,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: theme.textTheme.bodySmall!,
                          selectedDecoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                          ),
                          todayDecoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                          outsideDaysVisible: false,
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (events.isEmpty) return null;

                            final isPresent = controller.isDayPresent(date);
                            return Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isPresent ? Colors.green : Colors.red,
                                ),
                                child: Center(
                                  child: Text(
                                    date.day.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        onDaySelected: (selectedDay, focusedDay) {
                          controller.selectDay(selectedDay);
                        },
                        onPageChanged: (focusedDay) {
                          controller.changeFocusedDay(focusedDay);
                        },
                      ),
                    ),
                  ),
                ),
                if (state.selectedDay != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(context, 'Present', Colors.green),
                        const SizedBox(width: 20),
                        _buildLegendItem(context, 'Absent', Colors.red),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildAttendanceDetails(
                      context,
                      controller.getEventsForDay(state.selectedDay!),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 6,
          backgroundColor: color,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildAttendanceDetails(
      BuildContext context, List<Attendance> events) {
    final theme = Theme.of(context);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy,
                size: 48, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No attendance records for this day',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final attendance = events[index];
        final isPresent = attendance.isPresent;
        final theme = Theme.of(context);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPresent ? Colors.green : Colors.red,
                ),
                child: Icon(
                  isPresent ? Icons.check : Icons.close,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendance.metaData?.subject ?? 'Unknown',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${attendance.dateTime.hour}:${attendance.dateTime.minute.toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPresent ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPresent ? 'Present' : 'Absent',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
