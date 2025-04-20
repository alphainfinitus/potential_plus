import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/screens/timetable/timetable.dart';
import 'package:potential_plus/services/db_service.dart';

class ClassSelectionScreen extends ConsumerWidget {
  const ClassSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(classesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Select Class',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: classes.when(
        data: (classList) {
          if (classList == null || classList.isEmpty) {
            return Center(
              child: Text(
                'No classes found',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: classList.length,
            itemBuilder: (context, index) {
              final classItem = classList[index];
              return InkWell(
                onTap: () async {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // Fetch timetable using DbService
                  final timetable = await DbService.getClassTimetable(classItem.id);

                  // Dismiss loading indicator
                  Navigator.pop(context);

                  if (timetable != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimetablePage(
                          timeTable: timetable,
                          classId: classItem.id,
                        ),
                      ),
                    );
                  } else {
                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to load timetable',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onError,
                          ),
                        ),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.class_,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        classItem!.name,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}
