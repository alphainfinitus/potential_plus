import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user/app_user.dart';
import 'package:potential_plus/providers/teachers_provider/teachers_provider.dart';

class SelectTeacherDropdown extends ConsumerStatefulWidget {
  const SelectTeacherDropdown({ this.defaultValue, this.onValueChanged, super.key });

  final Function(AppUser value)? onValueChanged;
  final AppUser? defaultValue;

  @override
  ConsumerState<SelectTeacherDropdown> createState() => _SelectTeacherDropdownState();
}

class _SelectTeacherDropdownState extends ConsumerState<SelectTeacherDropdown> {
  AppUser? dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, AppUser>? institutionTeachers = ref.watch(teachersProvider).value;

    if (institutionTeachers == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (institutionTeachers.isEmpty) {
      return const Center(child: Text("No teachers found"));
    }

    return Row(
      children: [
        const Text("Teacher : "),
        const SizedBox(width: 16.0),
        DropdownButton(
          hint: const Text("Teacher"),
          value: dropdownValue,
          items: institutionTeachers.keys.map((String key) {
            return DropdownMenuItem(
              value: institutionTeachers[key],
              child: Text(institutionTeachers[key]!.name),
            );
          }).toList(),
          onChanged: (AppUser? newValue) {
            if(newValue == null) return;
            setState(() {
              dropdownValue = newValue;
            });
            widget.onValueChanged?.call(newValue);
          },
        ),
      ],
    );
  }
}