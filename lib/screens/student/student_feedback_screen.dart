import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/shared/app_bar_title.dart';

class StudentFeedbackScreen extends ConsumerWidget {
  const StudentFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: "Feedback"),
      ),
      body: const Center(
        child: Text("Feedback Screen - Coming Soon"),
      ),
    );
  }
} 