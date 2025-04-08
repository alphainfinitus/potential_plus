import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/repositories/institution_class_repository.dart';

class AddStudentsDialog extends ConsumerStatefulWidget {
  final Institution institution;
  final InstitutionClass institutionClass;

  const AddStudentsDialog({
    super.key,
    required this.institution,
    required this.institutionClass,
  });

  @override
  ConsumerState<AddStudentsDialog> createState() => _AddStudentsDialogState();
}

class _AddStudentsDialogState extends ConsumerState<AddStudentsDialog> {
  final Set<String> _selectedStudentIds = {};
  bool _isAddingStudents = false;

  Future<void> _addSelectedStudents() async {
    if (_selectedStudentIds.isEmpty) {
      return;
    }

    setState(() {
      _isAddingStudents = true;
    });

    try {
      for (final studentId in _selectedStudentIds) {
        await InstitutionClassRepository.addStudentToClass(
          studentId: studentId,
          classId: widget.institutionClass.id,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(TextLiterals.studentsAddedSuccessfully)),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${TextLiterals.failedToAddStudents}$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingStudents = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableStudentsAsync = ref.watch(
      studentsWithoutClassProvider(widget.institution.id),
    );

    return AlertDialog(
      title:
          Text('${TextLiterals.addStudentsTo}${widget.institutionClass.name}'),
      content: SizedBox(
        width: double.maxFinite,
        child: availableStudentsAsync.when(
          data: (students) {
            if (students.isEmpty) {
              return const Center(
                child: Text(TextLiterals.noStudentsAvailable),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    '${TextLiterals.selectStudentsToAdd}${widget.institutionClass.name}:'),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students.values.elementAt(index);
                      final isSelected =
                          _selectedStudentIds.contains(student.id);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedStudentIds.add(student.id);
                            } else {
                              _selectedStudentIds.remove(student.id);
                            }
                          });
                        },
                        title: Text(student.name),
                        subtitle: Text(student.username),
                        secondary: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        dense: true,
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('${TextLiterals.errorLoadingStudents}$error'),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(TextLiterals.cancel),
        ),
        ElevatedButton(
          onPressed: _isAddingStudents ? null : _addSelectedStudents,
          child: _isAddingStudents
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(TextLiterals.addStudents),
        ),
      ],
    );
  }
}
