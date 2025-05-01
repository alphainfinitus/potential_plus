import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final IconData? prefixIcon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final ColorScheme colorScheme;
  final String? errorText;
  final bool isExpanded;

  const CustomDropdown({
    super.key,
    required this.label,
    this.prefixIcon,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.colorScheme,
    this.errorText,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: colorScheme.primary)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
          errorText: errorText,
        ),
        value: value,
        items: items,
        onChanged: onChanged,
        icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
        dropdownColor: colorScheme.surface,
        isExpanded: isExpanded,
      ),
    );
  }
}
