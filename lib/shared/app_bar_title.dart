import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:go_router/go_router.dart';

class AppBarTitle extends ConsumerWidget {
  const AppBarTitle({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final currentRoute = GoRouterState.of(context).uri.path;

    return Row(
      children: [
        if (currentRoute == '/profile' && user.value != null)
          const Text('Profile')
        else if (currentRoute != '/profile' && user.value != null)
          Text(title ?? 'Potential Plus')
        else
          Text(title ?? 'Potential Plus'),
        const Spacer(),
        if (currentRoute != '/profile' && user.value != null)
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: const Icon(Icons.account_circle_outlined),
          ),
      ],
    );
  }
}
