import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/router/route_names.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/screens/student/student_home_screen/activity_feed/student_activity_feed.dart';
import 'package:potential_plus/shared/app_bar_title.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Institution? institution = ref.watch(institutionProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(),
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
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push(RouteNames.studentAttendance);
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('My Attendance'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StudentActivityFeed(appUser: appUser),
                  ),
                ),
              ],
            );
          },
          error: (error, _) =>
              const Center(child: Text(TextLiterals.authStatusUnkown)),
          loading: () => const Center(child: CircularProgressIndicator())),
    );
  }
}
