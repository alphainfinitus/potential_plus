import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/repositories/app_user_repository.dart';
import 'package:potential_plus/screens/timetable/timetable_controller.dart';
import 'package:potential_plus/shared/institution/select_teacher_dropdown.dart';
import 'package:potential_plus/utils.dart';

class TimetablePage extends ConsumerStatefulWidget {
  final TimeTable timeTable;
  final String classId;
  final bool isReadOnly;
  const TimetablePage({
    super.key,
    required this.timeTable,
    required this.classId,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends ConsumerState<TimetablePage> {
  int _selectedDayIndex = DateTime.now().weekday - 1;
  late PageController _pageController;
  late final TimetableController _controller;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedDayIndex);
    _controller = TimetableController(ref, widget.timeTable, widget.classId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Timetable',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Easily organize and monitor your class schedule. Keep track of your courses, optimize your time management, and enhance your productivity.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildDaySelector(colorScheme, textTheme),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
          SliverFillRemaining(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedDayIndex = index;
                });
              },
              itemCount: AppUtils.days.length,
              itemBuilder: (context, index) {
                return _buildDraggableEntryList(
                    index, colorScheme, textTheme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(ColorScheme colorScheme, TextTheme textTheme) {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: AppUtils.days.length,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDayIndex;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
              _pageController.jumpToPage(index);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 20.0 : 14.0,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        isSelected ? colorScheme.primary : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
              child: Text(
                AppUtils.days[index],
                style: textTheme.bodyLarge?.copyWith(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDraggableEntryList(
      int dayIndex, ColorScheme colorScheme, TextTheme textTheme) {
    final entrys = _controller.getEntrysForDay(dayIndex);

    if (widget.isReadOnly) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entrys.length,
        itemBuilder: (context, index) {
          return EntryCard(
            key: ValueKey(entrys[index].id),
            item: entrys[index],
            onTap: () {}, // Empty callback for read-only mode
            colorScheme: colorScheme,
            textTheme: textTheme,
          );
        },
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entrys.length + 1,
      onReorder: (oldIndex, newIndex) async {
        if (oldIndex < entrys.length && newIndex < entrys.length) {
          _controller.reorderEntrys(day: dayIndex, oldIndex: oldIndex, newIndex: newIndex);
        }
      },
      itemBuilder: (context, index) {
        if (index == entrys.length) {
          return _buildAddEntryCard(
            key: const ValueKey('add_entry_card'),
            colorScheme: colorScheme,
            textTheme: textTheme,
          );
        }
        return EntryCard(
          key: ValueKey(entrys[index].id),
          item: entrys[index],
          onTap: () {
            _showEditEntryDialog(entrys[index], dayIndex);
            setState(() {});
          },
          colorScheme: colorScheme,
          textTheme: textTheme,
        );
      },
    );
  }

  Widget _buildAddEntryCard({
    required Key key,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: _showAddEntryDialog,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Add New Entry',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEntryDialog() {
    final subjectController = TextEditingController();
    final teacherController = TextEditingController();
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Entry',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectTeacherDropdown(
                    onValueChanged: (value) =>
                        teacherController.text = value.id,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                            'Start Time',
                            style: textTheme.titleSmall,
                          ),
                          subtitle: Text(
                            startTime?.format(context) ?? 'Select time',
                            style: textTheme.bodyLarge,
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: colorScheme,
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              setState(() => startTime = time);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ListTile(
                          title: Text(
                            'End Time',
                            style: textTheme.titleSmall,
                          ),
                          subtitle: Text(
                            endTime?.format(context) ?? 'Select time',
                            style: textTheme.bodyLarge,
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: colorScheme,
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              setState(() => endTime = time);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          if (subjectController.text.isNotEmpty &&
                              startTime != null &&
                              endTime != null) {
                            final newEntry = _controller.createNewEntry(
                              subject: subjectController.text,
                              teacherId: teacherController.text,
                              startTime: startTime!,
                              endTime: endTime!,
                              day: _selectedDayIndex,
                              entryNumber: _controller
                                      .getEntrysForDay(_selectedDayIndex)
                                      .length +
                                  1,
                            );
                            _controller.addEntry(newEntry);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditEntryDialog(TimetableEntry entry, int dayIndex) {
    final subjectController = TextEditingController(text: entry.subject);
    final teacherController = TextEditingController(text: entry.teacherId);
    TimeOfDay? startTime = TimeOfDay(
      hour: entry.from!.toDate().hour,
      minute: entry.from!.toDate().minute,
    );
    TimeOfDay? endTime = TimeOfDay(
      hour: entry.to!.toDate().hour,
      minute: entry.to!.toDate().minute,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Entry',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SelectTeacherDropdown(
                    onValueChanged: (value) {
                      teacherController.text = value.id;
                    },
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(
                            'Start Time',
                            style: textTheme.titleSmall,
                          ),
                          subtitle: Text(
                            startTime?.format(context) ?? 'Select time',
                            style: textTheme.bodyLarge,
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: startTime!,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: colorScheme,
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              setState(() => startTime = time);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ListTile(
                          title: Text(
                            'End Time',
                            style: textTheme.titleSmall,
                          ),
                          subtitle: Text(
                            endTime?.format(context) ?? 'Select time',
                            style: textTheme.bodyLarge,
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: endTime!,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: colorScheme,
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              setState(() => endTime = time);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Container(
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: const Text('Are you sure you want to delete this entry? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _controller.removeEntry(entry);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    ),
                    // elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      Icon(Icons.delete_outline),
                      SizedBox(width: 8.0),
                      Text(
                        'Delete Entry',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          if (subjectController.text.isNotEmpty &&
                              startTime != null &&
                              endTime != null) {
                            final updatedEntry =
                                _controller.updateExistingEntry(
                              entry: entry,
                              subject: subjectController.text,
                              teacherId: teacherController.text,
                              startTime: startTime!,
                              endTime: endTime!,
                            );

                            _controller.updateEntry(updatedEntry);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class EntryCard extends StatelessWidget {
  final TimetableEntry item;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const EntryCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.subject,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Entry ${item.entryNumber}',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.from!.toDate().hour}:${item.from!.toDate().minute.toString().padLeft(2, '0')} - ${item.to!.toDate().hour}:${item.to!.toDate().minute.toString().padLeft(2, '0')}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  FutureBuilder(
                      future: AppUserRepository.fetchUserData(item.teacherId),
                      builder: (context, snapshot) {
                        return Text(snapshot.data?.name ?? "Unknown");
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
