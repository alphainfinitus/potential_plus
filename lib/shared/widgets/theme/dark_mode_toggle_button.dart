import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/providers/current_theme_provider/current_theme_provider.dart';
import 'package:potential_plus/constants/responsive.dart';

/// A widget that displays a toggle button for switching between light and dark themes.
///
/// This widget includes:
/// - An icon indicating the current theme (sun/moon)
/// - A text label showing the current theme mode
/// - A switch for toggling between themes
/// - Proper styling and responsive design
class DarkModeToggleButton extends ConsumerWidget {
  const DarkModeToggleButton({super.key});

  /// Text constants for the widget
  static const _darkModeText = 'Dark Mode';
  static const _lightModeText = 'Light Mode';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(currentThemeNotifierProvider);
    final isDarkMode = currentTheme.brightness == Brightness.dark;

    return InkWell(
      onTap: _handleThemeToggle(ref),
      borderRadius: BorderRadius.circular(
          Responsive.getRadius(context, ResponsiveSizes.radiusMedium)),
      child: _buildToggleContainer(context, isDarkMode, ref),
    );
  }

  /// Builds the container that holds the theme toggle UI
  Widget _buildToggleContainer(
    BuildContext context,
    bool isDarkMode,
    WidgetRef ref,
  ) {
    return Container(
      padding: EdgeInsets.all(
          Responsive.getPadding(context, ResponsiveSizes.paddingMedium)),
      decoration: _buildContainerDecoration(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildThemeInfo(context, isDarkMode),
          _buildThemeSwitch(isDarkMode, ref),
        ],
      ),
    );
  }

  /// Builds the decoration for the container
  BoxDecoration _buildContainerDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(
          Responsive.getRadius(context, ResponsiveSizes.radiusMedium)),
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
      ),
    );
  }

  /// Builds the theme information section (icon and text)
  Widget _buildThemeInfo(BuildContext context, bool isDarkMode) {
    return Row(
      children: [
        Icon(
          isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(
            width: Responsive.getMargin(context, ResponsiveSizes.marginMedium)),
        Text(
          isDarkMode ? _darkModeText : _lightModeText,
          style: _buildTextStyle(context),
        ),
      ],
    );
  }

  /// Builds the theme switch widget
  Widget _buildThemeSwitch(bool isDarkMode, WidgetRef ref) {
    return Switch(
      value: isDarkMode,
      onChanged: (_) => _handleThemeToggle(ref)(),
      activeColor: Theme.of(ref.context).colorScheme.primary,
    );
  }

  /// Builds the text style for the theme mode text
  TextStyle _buildTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: Responsive.getFontSize(context, 16),
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Returns a function to handle theme toggling
  VoidCallback _handleThemeToggle(WidgetRef ref) {
    return () {
      ref.read(currentThemeNotifierProvider.notifier).toggleTheme();
    };
  }
}
