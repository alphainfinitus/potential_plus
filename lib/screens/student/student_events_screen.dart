import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/shared/app_bar_title.dart';

class StudentEventsScreen extends ConsumerWidget {
  const StudentEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: "Events"),
      ),
      body: const Center(
        child: Text("Events Screen - Coming Soon"),
      ),
    );
  }
} 