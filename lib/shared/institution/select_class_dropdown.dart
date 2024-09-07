import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/classes_provider.dart';

class SelectClassDropdown extends ConsumerStatefulWidget {
  const SelectClassDropdown({ this.defaultValue, this.onValueChanged, super.key });

  final Function(InstitutionClass value)? onValueChanged;
  final InstitutionClass? defaultValue;

  @override
  ConsumerState<SelectClassDropdown> createState() => _SelectClassDropdownState();
}

class _SelectClassDropdownState extends ConsumerState<SelectClassDropdown> {
  InstitutionClass? dropdownValue;

  @override
  void initState() {
    dropdownValue = widget.defaultValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, InstitutionClass>? classes = ref.watch(classesProvider).value;

    if (classes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (classes.isEmpty) {
      return const Center(child: Text("No classes found"));
    }

    return Row(
      children: [
        const Text("Select Class : "),
        const SizedBox(width: 16.0),
        DropdownButton(
          hint: const Text("Select Class"),
          value: dropdownValue,
          items: classes.keys.map((String key) {
            return DropdownMenuItem(
              value: classes[key],
              child: Text(classes[key]!.name),
            );
          }).toList(),
          onChanged: (InstitutionClass? newValue) {
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