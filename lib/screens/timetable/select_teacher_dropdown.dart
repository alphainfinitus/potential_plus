import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
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
    final List<AppUser>? users = ref.watch(teachersProvider).value?.values.toList();

    if (users == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return const Center(child: Text("No users found"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<AppUser>(
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
          hint: const Text("Select a class"),
          value: dropdownValue,
          items: users.map((AppUser appUser) {
            return DropdownMenuItem(
              value: appUser,
              child: Text(appUser.name),
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