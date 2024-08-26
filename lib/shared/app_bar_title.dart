import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/shared/dark_mode_toggle_button.dart';
class AppBarTitle extends StatelessWidget {
  const AppBarTitle({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Text(
          title ?? TextLiterals.appTitle,
          style: title == null ? GoogleFonts.micro5(fontSize: 42) : null,
        ),
        const Expanded(child: SizedBox()),
        const DarkModeToggleButton(),
      ]
    );
			
  }
}