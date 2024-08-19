import 'package:flutter/material.dart';
import 'package:potential_plus/models/app_user.dart';

class StudentActivityFeed extends StatelessWidget {
  const StudentActivityFeed({super.key, required this.appUser });

  final AppUser appUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:[
          Center(child: Text('Activity Feed for ${appUser.name} ')),

          const SizedBox(height: 16.0,),
        ]
      ),
    );
  }
}