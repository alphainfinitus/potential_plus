import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/route_paths.dart';
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
							context.go(AppRoutes.login.path);
						});
						return null;
					}

					if (institution == null) {
						return const Center(child: CircularProgressIndicator());
					}

					return SingleChildScrollView(
						child: Padding(
							padding: const EdgeInsets.all(16.0),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									const Text(
										'Potential+',
										style: TextStyle(
											fontSize: 32,
											fontWeight: FontWeight.bold,
											color: Colors.blue,
										),
									),
									const SizedBox(height: 24),
									GridView.count(
										shrinkWrap: true,
										physics: const NeverScrollableScrollPhysics(),
										crossAxisCount: 2,
										mainAxisSpacing: 16,
										crossAxisSpacing: 16,
										children: [
											_QuickActionCard(
												icon: Icons.check_circle_outline,
												title: 'Attendance',
												onTap: () => context.push(RoutePaths.studentAttendance),
											),
											_QuickActionCard(
												icon: Icons.bar_chart,
												title: 'Results',
												onTap: () => context.push(RoutePaths.studentResults),
											),
											_QuickActionCard(
												icon: Icons.calendar_today,
												title: 'Events',
												onTap: () => context.push(RoutePaths.studentEvents),
											),
											_QuickActionCard(
												icon: Icons.chat,
												title: 'Feedback',
												onTap: () => context.push(RoutePaths.studentFeedback),
											),
										],
									),
									const SizedBox(height: 24),
									const Text(
										'Recent Activity',
										style: TextStyle(
											fontSize: 24,
											fontWeight: FontWeight.bold,
										),
									),
									const SizedBox(height: 16),
									SizedBox(
										height: 400,
										child: StudentActivityFeed(appUser: appUser),
									),
								],
							),
						),
					);
				},
				error: (error, _) => const Center(child: Text(TextLiterals.authStatusUnkown)),
				loading: () => const Center(child: CircularProgressIndicator()),
			),
		);
	}
}

class _QuickActionCard extends StatelessWidget {
	final IconData icon;
	final String title;
	final VoidCallback onTap;

	const _QuickActionCard({
		required this.icon,
		required this.title,
		required this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		return Card(
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(16),
			),
			color: Theme.of(context).colorScheme.surface,
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(16),
				child: Padding(
					padding: const EdgeInsets.all(16),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Icon(
								icon,
								size: 32,
								color: Colors.blue,
							),
							const SizedBox(height: 8),
							Text(
								title,
								style: const TextStyle(
									fontSize: 16,
									fontWeight: FontWeight.w500,
								),
							),
						],
					),
				),
			),
		);
	}
}