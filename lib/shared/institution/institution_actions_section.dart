import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InstitutionActionsSection extends StatelessWidget {
  const InstitutionActionsSection(
      {super.key, required this.title, required this.actions});

  final String title;
  final Map<String, String> actions; // action title and url to be called

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(title),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8.0,
          children: actions.entries.map((actionItem) {
            return ElevatedButton(
              onPressed: () => context.push(actionItem.value),
              child: Text(actionItem.key),
            );
          }).toList(),
        ),
      ),
    ]);
  }
}
