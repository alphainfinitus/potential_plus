import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';

class ClassStudentsList extends ConsumerWidget {
  final InstitutionClass selectedClass;

  const ClassStudentsList({
    super.key,
    required this.selectedClass,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Map<String, AppUser>> studentsAsync =
        ref.watch(classStudentsProvider(selectedClass.id));

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(TextLiterals.noStudentsInClass),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(TextLiterals.studentsInThisClass,
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students.values.elementAt(index);
                return ListTile(
                  dense: true,
                  title: Text(student.name),
                  subtitle: Text(student.username),
                  leading: const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 16),
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('${TextLiterals.errorLoadingStudents}$error')),
    );
  }
}
