import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';

class AppBarTitle extends ConsumerWidget {
  const AppBarTitle({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final user = ref.watch(authProvider);

    return Row(
      children: [
        if (currentRoute == AppRoutes.profile.path && user.value != null)
          Text(user.value!.name),

        if (currentRoute != AppRoutes.profile.path && user.value != null)
          Expanded(
            child: Text(
              title ?? TextLiterals.appTitle,
              overflow: TextOverflow.ellipsis,
              style: title == null ?
                GoogleFonts.micro5(fontSize: 42) :
                const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

        if (currentRoute != AppRoutes.profile.path && user.value != null)
          IconButton(
            onPressed: () {
              context.push(AppRoutes.profile.path);
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),

        if (user.value == null)
          Text(title ?? ""),
      ]
    );
  }
}