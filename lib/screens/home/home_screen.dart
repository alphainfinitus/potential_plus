import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/providers/auth_provider.dart';
import 'package:potential_plus/shared/app_bar_title.dart';

class HomeScreen extends ConsumerWidget {
	const HomeScreen({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final user = ref.watch(authProvider);

		return Scaffold(
			appBar: AppBar(
				title: const AppBarTitle(),
			),
			body: Center(
				child: Text(
					'This is the home screen for ${user.name}',
				),
			),
		);
	}
}