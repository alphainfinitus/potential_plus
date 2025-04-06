import 'package:flutter/material.dart';
import 'package:potential_plus/models/app_user.dart';

class StudentListItem extends StatelessWidget {
  final AppUser student;

  const StudentListItem({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(student.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.email),
            Text('ID: ${student.username}'),
          ],
        ),
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        trailing: student.classId == null
            ? const Chip(
                label: Text('No Class'),
                backgroundColor: Colors.amber,
              )
            : null,
      ),
    );
  }
}
