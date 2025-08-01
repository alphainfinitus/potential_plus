import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/router/route_names.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/services/token_manager.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/shared/institution/institution_actions_section.dart';

class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Institution? institution = ref.watch(institutionProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: institution?.name),
      ),
      body: user.when(
          data: (appUser) {
            // Not logged in, redirect to login screen
            if (appUser == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(RouteNames.login);
              });
              return null;
            }

            if (institution == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // Verify FCM token when dashboard loads
            WidgetsBinding.instance.addPostFrameCallback((_) {
              TokenManager.verifyTokenOnDashboard();
            });

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Good Morning, ${appUser.name.split(' ')[0]} ☀️',
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      const SizedBox(
                        height: 32.0,
                      ),
                      const InstitutionActionsSection(
                          title: 'Daily Actions :',
                          actions: {
                            'Mark Attendance': RouteNames.teacherMarkAttendance,
                          }),
                    ]),
              ),
            );
          },
          error: (error, _) =>
              const Center(child: Text(TextLiterals.authStatusUnkown)),
          loading: () => const Center(child: CircularProgressIndicator())),
    );
  }
}
