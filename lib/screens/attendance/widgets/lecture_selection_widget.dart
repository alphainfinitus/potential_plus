import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart';
import 'package:potential_plus/widgets/custom_dropdown.dart';

class LectureSelectionWidget extends ConsumerWidget {
  const LectureSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClass = ref.watch(selectedClassProvider);
    final selectedLecture = ref.watch(selectedLectureProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (selectedClass == null) return const SizedBox.shrink();

    final timetableAsync = ref.watch(classTimetableProvider(selectedClass.id));

    return timetableAsync.when(
      data: (timetable) {
        if (timetable == null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.errorContainer,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: colorScheme.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No timetable available for this class',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final dayOfWeek = selectedDate.weekday - 1;
        final lectures =
            timetable.entries.where((entry) => entry.day == dayOfWeek).toList();

        if (lectures.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.tertiaryContainer,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.event_busy, color: colorScheme.tertiary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No lectures scheduled for this day',
                    style: TextStyle(
                      color: colorScheme.tertiary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return CustomDropdown<TimetableEntry>(
          label: 'Select Lecture',
          value: lectures.firstWhere(
            (l) => selectedLecture?.id == l.id,
            orElse: () => lectures.first,
          ),
          items: lectures.map((lecture) {
            String timeInfo = '';
            if (lecture.from != null && lecture.to != null) {
              final startTime = TimeOfDay.fromDateTime(lecture.from!.toDate());
              final endTime = TimeOfDay.fromDateTime(lecture.to!.toDate());
              timeInfo =
                  ' (${startTime.format(context)} - ${endTime.format(context)})';
            }

            return DropdownMenuItem(
              value: lecture,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.subject, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${lecture.subject}$timeInfo',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(selectedLectureProvider.notifier).state = value;
            }
          },
          colorScheme: colorScheme,
          isExpanded: true,
        );
      },
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: LinearProgressIndicator()),
      ),
      error: (error, stack) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.errorContainer,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error loading timetable',
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
