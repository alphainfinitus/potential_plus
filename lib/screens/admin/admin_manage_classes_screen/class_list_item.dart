import 'package:flutter/material.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/screens/admin/admin_manage_classes_screen/class_students_list.dart';
import 'package:potential_plus/utils.dart';

class ClassListItem extends StatefulWidget {
  final InstitutionClass classItem;
  final Institution institution;
  final Function(InstitutionClass) onAddStudents;

  const ClassListItem({
    super.key,
    required this.classItem,
    required this.institution,
    required this.onAddStudents,
  });

  @override
  State<ClassListItem> createState() => _ClassListItemState();
}

class _ClassListItemState extends State<ClassListItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(widget.classItem.name),
            subtitle: Text(
                '${TextLiterals.created}${AppUtils.formatDate(widget.classItem.createdAt)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => widget.onAddStudents(widget.classItem),
                  tooltip: TextLiterals.addStudents,
                ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  tooltip:
                      _isExpanded ? TextLiterals.collapse : TextLiterals.expand,
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ClassStudentsList(selectedClass: widget.classItem),
            ),
        ],
      ),
    );
  }
}
