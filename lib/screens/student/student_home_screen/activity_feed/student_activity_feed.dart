import 'package:flutter/material.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/shared/logout_button.dart';

class StudentActivityFeed extends StatelessWidget {
  const StudentActivityFeed({super.key, required this.appUser });

  final AppUser appUser;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          const LogoutButton(),
        ]
      ),
    );
  }
}