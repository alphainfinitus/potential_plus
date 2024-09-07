import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/teachers_provider.dart';
import 'package:potential_plus/shared/institution/select_teacher_dropdown.dart';
import 'package:potential_plus/utils.dart';

class AdminEditPeriodDialog extends ConsumerStatefulWidget {
  const AdminEditPeriodDialog({
    required this.periodIndex,
    required this.dayofWeekIndex,
    this.timeTableEntry,
    super.key
  });

  final int periodIndex;
  final int dayofWeekIndex;
  final TimetableEntry? timeTableEntry;

  @override
  ConsumerState<AdminEditPeriodDialog> createState() => _AdminEditPeriodDialogState();
}

class _AdminEditPeriodDialogState extends ConsumerState<AdminEditPeriodDialog> {
  final TextEditingController _subjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subjectController.text = widget.timeTableEntry?.subject ?? '';
  }

  String? _errorMessage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Map<String, AppUser>? institutionTeachers = ref.watch(teachersProvider).value;

    if(institutionTeachers == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AlertDialog(
      title: Text("${AppUtils.getDayOfWeekByIndex(widget.dayofWeekIndex)} - Period #${ widget.periodIndex +1 }"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          SelectTeacherDropdown(defaultValue: institutionTeachers[widget.timeTableEntry?.teacherId]),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Save"),
        )
      ],
    );
  }
}