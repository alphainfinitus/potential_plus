import 'package:flutter/material.dart';
import 'package:potential_plus/theme/input_decorations.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final ColorScheme colorScheme;
  final bool isExpanded;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.colorScheme,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: isExpanded,
      decoration: SharedInputDecorations.getDropdown(
        context: context,
        labelText: label,
        iconColor: colorScheme.primary,
      ),
      dropdownColor: colorScheme.surface,
      icon: const SizedBox.shrink(),
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 13,
      ),
    );
  }
}
