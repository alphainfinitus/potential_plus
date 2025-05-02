import 'package:flutter/material.dart';

class SharedInputDecorations {
  static InputDecoration getDefault({
    required BuildContext context,
    required String labelText,
    Widget? suffixIcon,
    bool filled = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      suffixIcon: suffixIcon,
      filled: filled,
      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  static InputDecoration getDropdown({
    required BuildContext context,
    required String labelText,
    required Color iconColor,
  }) {
    return getDefault(
      context: context,
      labelText: labelText,
      suffixIcon: Icon(Icons.arrow_drop_down, color: iconColor, size: 22),
    );
  }
}
