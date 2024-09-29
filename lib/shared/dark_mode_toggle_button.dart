import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/providers/current_theme_provider/current_theme_provider.dart';

class DarkModeToggleButton extends ConsumerWidget {
  const DarkModeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
		final currentTheme = ref.watch(currentThemeNotifierProvider);
    bool isDark = currentTheme.brightness == Brightness.dark;

    void onThemeToggle() {
      ref.read(currentThemeNotifierProvider.notifier).toggleTheme();
    }

    return IconButton(
      onPressed: onThemeToggle,
      icon: Icon( isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
    );
  }
}