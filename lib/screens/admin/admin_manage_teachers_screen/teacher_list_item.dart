import 'package:flutter/material.dart';
import 'package:potential_plus/models/app_user.dart';

class TeacherListItem extends StatelessWidget {
  final AppUser teacher;

  const TeacherListItem({
    super.key,
    required this.teacher,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(teacher.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(teacher.email),
            Text('ID: ${teacher.username}'),
          ],
        ),
        leading: const CircleAvatar(
          backgroundColor: Colors.blueGrey,
          child: Icon(Icons.person),
        ),
      ),
    );
  }
}
