import 'package:flutter/material.dart';
import 'package:potential_plus/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:[
          const Center(child: Text('Profile')),

          const SizedBox(height: 16.0,),

          FilledButton.tonal(
            onPressed: () async {
              await AuthService.signOut();
            },
            child: const Text('Sign Out')
          ),
        ]
      ),
    );
  }
}