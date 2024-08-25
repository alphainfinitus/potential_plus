import 'package:flutter/material.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/shared/logout_button.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key, required this.appUser });

  final AppUser appUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:[
            Center(child: Text('Teacher Screen for ${appUser.name} from ${appUser.institutionId} ')),
            const SizedBox(height: 16.0,),
            const LogoutButton(),
          ]
        ),
      ),
    );
  }
}