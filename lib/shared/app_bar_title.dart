import 'package:flutter/material.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/shared/dark_mode_toggle_button.dart';
class AppBarTitle extends StatelessWidget {
  const AppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {

    void onLoginPressed() {
      Navigator.of(context).pushNamed('/login');
    }

    return Row(
      children: [
        const Text(TextLiterals.appTitle),
        const Expanded(child: SizedBox()),
        const DarkModeToggleButton(),
        FilledButton.tonal(
          onPressed: onLoginPressed,
          child: const Text('Login')
        ),
      ]
    );
			
  }
}