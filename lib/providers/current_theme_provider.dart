
import 'package:flutter/material.dart';
import 'package:potential_plus/constants/app_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_theme_provider.g.dart';

@riverpod
class CurrentThemeNotifier extends _$CurrentThemeNotifier {

  // initial value
  @override
  ThemeData build() => AppTheme.darkTheme;

  void toggleTheme() {
    state = state.brightness == Brightness.dark ? AppTheme.lightTheme : AppTheme.darkTheme;
  }
}
