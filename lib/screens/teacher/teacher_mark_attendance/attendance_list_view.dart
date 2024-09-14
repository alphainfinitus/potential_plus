import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/students_provider.dart';

class AttendanceListView extends ConsumerStatefulWidget {
  const AttendanceListView({super.key, required this.institutionClass});

  final InstitutionClass institutionClass;

  @override
  ConsumerState<AttendanceListView> createState() => _AttendanceListViewState();
}

class _AttendanceListViewState extends ConsumerState<AttendanceListView> {
  @override
  Widget build(BuildContext context) {
    final InstitutionClass institutionClass = widget.institutionClass;
    final Map<String, AppUser>? students = ref.watch(studentsProvider).value;

    if (students == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (students.isEmpty) {
      return Center(child: Text('No students found for ${institutionClass.name}'));
    }

    return ListView.builder(
      itemCount: students.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final student = students.values.elementAt(index);
        return ListTile(
          title: Text(student.name),
          trailing: Checkbox(
            value: false,
            onChanged: (bool? value) {
              // Empty function
            },
          ),
        );
      },
    );
  }
}