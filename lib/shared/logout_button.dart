import 'package:flutter/material.dart';
import 'package:potential_plus/services/auth_service.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: () async {
        await AuthService.signOut();
      },
      child: const Text('Sign Out')
    );
  }
}