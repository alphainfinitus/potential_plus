import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/attendance_provider/attendance_provider.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/widgets/custom_dropdown.dart';

class ClassSelectionWidget extends ConsumerWidget {
  const ClassSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClass = ref.watch(selectedClassProvider);
    final classesAsync = ref.watch(classesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return classesAsync.when(
      data: (classes) => CustomDropdown<InstitutionClass>(
        label: 'Class',
        value: selectedClass,
        items: classes!.map((cls) {
          return DropdownMenuItem(
            value: cls,
            child: Text(
              cls.name,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          ref.read(selectedClassProvider.notifier).state = value;
          ref.read(selectedLectureProvider.notifier).state = null;
        },
        colorScheme: colorScheme,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Error loading classes: $error',
                style: TextStyle(color: colorScheme.error, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
