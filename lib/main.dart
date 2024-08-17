import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/providers/current_theme_provider.dart';
import 'package:potential_plus/screens/home/home_screen.dart';

void main() {
	runApp(const ProviderScope(child: AppRootWidget()));
}

class AppRootWidget extends ConsumerWidget {
	const AppRootWidget({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final currentTheme = ref.watch(currentThemeNotifierProvider);

		return MaterialApp(
			title: TextLiterals.appTitle,
			theme: currentTheme,
			home: const HomeScreen(),
		);
	}
}