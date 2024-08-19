import 'package:flutter/material.dart';
import 'package:potential_plus/shared/app_bar_title.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
			appBar: AppBar(
				title: const AppBarTitle(title: "Forgot Password ?",),
			),
			body: const Center(
				child: Text(
					'This is the forgot password screen',
				),
			),
		);
  }
}