import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart';
import 'package:potential_plus/theme/input_decorations.dart';
import 'package:intl/intl.dart';

class DateSelectionWidget extends ConsumerWidget {
  const DateSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(DateTime.now().year),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          ref.read(selectedDateProvider.notifier).state = date;
        }
      },
      child: InputDecorator(
        decoration: SharedInputDecorations.getDropdown(
          context: context,
          labelText: 'Date',
          iconColor: colorScheme.primary,
        ),
        child: Text(
          DateFormat('MMM d, y').format(selectedDate),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
