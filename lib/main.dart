import 'package:flutter/material.dart';
import 'package:potential_plus/constants/app_colors.dart';
import 'package:potential_plus/screens/home/home_screen.dart';

void main() {
  runApp(const AppRootWidget());
}

class AppRootWidget extends StatelessWidget {
  const AppRootWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Potential Plus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.getColor("seed")),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}