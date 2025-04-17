import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/models/attendance.dart';
import 'package:potential_plus/repositories/institution_class_repository.dart';
import 'package:potential_plus/providers/institution_provider/institution_provider.dart';
import 'package:potential_plus/screens/teacher/teacher_mark_attendance/mark_attendance_screen.dart';

class AttendanceListView extends ConsumerStatefulWidget {
  const AttendanceListView({
    super.key,
    required this.institutionClass,
  });

  final InstitutionClass institutionClass;

  @override
  ConsumerState<AttendanceListView> createState() => _AttendanceListViewState();
}

class _AttendanceListViewState extends ConsumerState<AttendanceListView> {
  Map<String, List<Attendance>> attendanceMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    setState(() {
      isLoading = true;
    });

    try {
      final institution = ref.read(institutionProvider).value!;
      print('Fetching attendance for institution: ${institution.id}');
      print('Class ID: ${widget.institutionClass.id}');
      print('Date: ${DateTime.now()}');

      final List<Attendance> attendanceList =
          await InstitutionClassRepository.fetchClassAttendanceByDate(
        institutionId: institution.id,
        institutionClassId: widget.institutionClass.id,
        date: DateTime.now(),
      );

      print('Fetched ${attendanceList.length} attendance records');

      // Group attendance by student
      final Map<String, List<Attendance>> groupedAttendance = {};
      for (var attendance in attendanceList) {
        print('Processing attendance for student: ${attendance.userId}');
        groupedAttendance
            .putIfAbsent(attendance.userId, () => [])
            .add(attendance);
      }

      print('Grouped attendance into ${groupedAttendance.length} students');

      setState(() {
        attendanceMap = groupedAttendance;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch attendance: $e')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Widget _buildAttendanceDots(List<Attendance> attendances) {
    return Row(
      children: [
        const Text('Today\'s Attendance: '),
        ...attendances.map((attendance) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: attendance.isPresent ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final students =
        ref.watch(classStudentsProvider(widget.institutionClass.id)).value;

    if (students == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: _buildBody(context, ref, students),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MarkAttendanceScreen(
                institutionClass: widget.institutionClass,
              ),
            ),
          ).then((_) => _fetchAttendance());
        },
        tooltip: 'Add Attendance',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, Map<String, AppUser> students) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text('Today\'s Attendance',
            style: Theme.of(context).textTheme.titleLarge),
        Expanded(
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students.values.elementAt(index);
              final attendances = attendanceMap[student.id] ?? [];

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (attendances.isEmpty)
                        const Text(
                          'No attendance marked today',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        _buildAttendanceDots(attendances),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AddAttendanceDialog extends StatefulWidget {
  const AddAttendanceDialog({super.key});

  @override
  State<AddAttendanceDialog> createState() => _AddAttendanceDialogState();
}

class _AddAttendanceDialogState extends State<AddAttendanceDialog> {
  bool isPresent = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Attendance'),
      content: Row(
        children: [
          const Text('Status: '),
          const Text('Present'),
          Radio<bool>(
            value: true,
            groupValue: isPresent,
            onChanged: (bool? value) {
              setState(() {
                isPresent = value ?? true;
              });
            },
          ),
          const Text('Absent'),
          Radio<bool>(
            value: false,
            groupValue: isPresent,
            onChanged: (bool? value) {
              setState(() {
                isPresent = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, isPresent);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class EditAttendanceDialog extends StatefulWidget {
  const EditAttendanceDialog({
    super.key,
    required this.initialIsPresent,
  });

  final bool initialIsPresent;

  @override
  State<EditAttendanceDialog> createState() => _EditAttendanceDialogState();
}

class _EditAttendanceDialogState extends State<EditAttendanceDialog> {
  late bool isPresent;

  @override
  void initState() {
    super.initState();
    isPresent = widget.initialIsPresent;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Attendance'),
      content: Row(
        children: [
          const Text('Status: '),
          const Text('Present'),
          Radio<bool>(
            value: true,
            groupValue: isPresent,
            onChanged: (bool? value) {
              setState(() {
                isPresent = value ?? true;
              });
            },
          ),
          const Text('Absent'),
          Radio<bool>(
            value: false,
            groupValue: isPresent,
            onChanged: (bool? value) {
              setState(() {
                isPresent = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, isPresent);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
