import 'package:flutter/material.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/services/auth_service.dart';

class StudentActivityFeed extends StatelessWidget {
  const StudentActivityFeed({super.key, required this.appUser });

  final AppUser appUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:[
            Center(child: Text('Activity Feed for ${appUser.name} ')),

            const SizedBox(height: 32.0,),

            for (var i = 0; i < 20; i++) 
              ListTile(
                minTileHeight: 100.0,
                title: Text('Activity ${i+1}'),
                subtitle: Text('Details for Activity ${i+1}'),
                leading: Text('${i+1}'),
              ),
        
            const SizedBox(height: 16.0,),
            
            FilledButton.tonal(
              onPressed: () async {
                await AuthService.signOut();
              },
              child: const Text('Sign Out')
            ),
          ]
        ),
      ),
    );
  }
}