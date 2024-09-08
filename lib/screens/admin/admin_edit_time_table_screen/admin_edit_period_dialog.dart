import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/classes_provider.dart';
import 'package:potential_plus/providers/teachers_provider.dart';
import 'package:potential_plus/shared/institution/select_teacher_dropdown.dart';
import 'package:potential_plus/utils.dart';

class AdminEditPeriodDialog extends ConsumerStatefulWidget {
  const AdminEditPeriodDialog({
    required this.institution,
    required this.selectedClass,
    required this.periodIndex,
    required this.dayofWeekIndex,
    this.currentTimeTableEntry,
    super.key
  });

  final Institution institution;
  final InstitutionClass selectedClass;
  final int periodIndex;
  final int dayofWeekIndex;
  final TimetableEntry? currentTimeTableEntry;

  @override
  ConsumerState<AdminEditPeriodDialog> createState() => _AdminEditPeriodDialogState();
}

class _AdminEditPeriodDialogState extends ConsumerState<AdminEditPeriodDialog> {
  final TextEditingController _subjectController = TextEditingController();
  AppUser? selectedTeacher;

  @override
  void initState() {
    super.initState();
    _subjectController.text = widget.currentTimeTableEntry?.subject ?? '';
  }

  String? _errorMessage;
  bool _isLoading = false;

  Future savePeriodDetails() async {
    if(selectedTeacher == null) {
      setState(() {
        _errorMessage = 'Please select a teacher';
        _isLoading = false;
      });

      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call the update method and wait for it to complete
      await updateClassPeriodDetails(
        widget.institution,
        widget.selectedClass,
        widget.dayofWeekIndex,
        widget.periodIndex,
        TimetableEntry(
          subject: _subjectController.text,
          teacherId: selectedTeacher!.id,
        ),
      );

      // Invalidate the provider to refresh the classes
      ref.invalidate(classesProvider);

      // Close the dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again later.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, AppUser>? institutionTeachers = ref.watch(teachersProvider).value;

    setState(() {
      selectedTeacher = institutionTeachers?[widget.currentTimeTableEntry?.teacherId];
    });

    if(institutionTeachers == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AlertDialog(
      title: Text("${AppUtils.getDayOfWeekByIndex(widget.dayofWeekIndex)} - Period #${ widget.periodIndex +1 }"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _isLoading ? [
            Center(
              child: Transform.scale(
                scale: 0.5,
                child: const CircularProgressIndicator()
              )
            ),
          ] : [
            if(_errorMessage != null) Text(_errorMessage ?? 'Something went wrong. Please try again later.'),

            TextFormField(
              controller: _subjectController,
              readOnly: _isLoading,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(labelText: 'Subject'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid subject';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            SelectTeacherDropdown(
              defaultValue: institutionTeachers[widget.currentTimeTableEntry?.teacherId],
              onValueChanged: (value) => setState(() { selectedTeacher = value; }),
            ),
          ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),

          child: const Text("Close"),
        ),
        FilledButton(
          onPressed: _isLoading ? null : () => savePeriodDetails(),
          child: const Text("Save"),
        )
      ],
    );
  }
}