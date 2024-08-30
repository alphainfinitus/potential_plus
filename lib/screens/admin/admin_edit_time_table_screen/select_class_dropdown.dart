import 'package:flutter/material.dart';

class SelectClassDropdown extends StatefulWidget {
  const SelectClassDropdown({super.key});

  @override
  State<SelectClassDropdown> createState() => _SelectClassDropdownState();
}

class _SelectClassDropdownState extends State<SelectClassDropdown> {
  String dropdownValue = "Class 1";

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Select Class : "),
        const SizedBox(width: 16.0),
        Expanded(
          child: DropdownButton(
            value: dropdownValue,
            items: const [
              DropdownMenuItem(
                value: "Class 1",
                child: Text("Class 1 A"),
              ),
              DropdownMenuItem(
                value: "Class 2",
                child: Text("Class 1 B"),
              ),
              DropdownMenuItem(
                value: "Class 3",
                child: Text("Class 2 A"),
              ),
            ],
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }
}