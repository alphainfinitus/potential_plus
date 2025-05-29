import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/activity.dart';
import 'package:potential_plus/constants/activity_type.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/services/db_service.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:intl/intl.dart';
import 'package:cuid2/cuid2.dart';

class AdminAnnouncementsScreen extends ConsumerStatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  ConsumerState<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState
    extends ConsumerState<AdminAnnouncementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Activity> _activities = [];
  bool _isLoading = true;

  // Create announcement tab controllers
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _teacherIdController = TextEditingController();
  TargetType _selectedRecipient = TargetType.ALL;
  bool _isCreatingActivity = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    _studentIdController.dispose();
    _teacherIdController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    final appUser = ref.read(authProvider).value;
    if (appUser == null) {
      print('Error: appUser is null in _loadActivities');
      return;
    }

    print('Loading announcements for institution: ${appUser.institutionId}');

    setState(() {
      _isLoading = true;
    });

    try {
      final activities =
          await DbService.getInstitutionAnnouncements(appUser.institutionId);

      print('Loaded ${activities.length} announcements');

      if (activities.isEmpty) {
        print('No announcements found. This might be unexpected.');
        // Consider creating a sample announcement for testing
        await _createSampleAnnouncement(appUser);
        // Try loading again
        final retryActivities =
            await DbService.getInstitutionAnnouncements(appUser.institutionId);
        setState(() {
          _activities = retryActivities;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _loadActivities: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createSampleAnnouncement(AppUser appUser) async {
    print('Creating sample announcement for testing');
    try {
      final now = DateTime.now();

      // Create a sample announcement
      final activity = Activity(
        id: cuid(),
        userId: appUser.id,
        targetType: TargetType.ALL,
        activityType: ActivityType.announcement,
        activityRefId: "",
        createdAt: now,
        updatedAt: now,
        institutionId: appUser.institutionId,
        title: "Sample Announcement",
        message:
            "This is a sample announcement created automatically for testing.",
      );

      await DbService.activitiesCollRef().doc(activity.id).set(activity);
      print('Sample announcement created successfully with ID: ${activity.id}');
    } catch (e) {
      print('Error creating sample announcement: $e');
    }
  }

  Future<void> _createActivity() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in the title and message fields')),
      );
      return;
    }

    if (_selectedRecipient == TargetType.SPECIFIC_STUDENT &&
        _studentIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a student ID')),
      );
      return;
    }

    if (_selectedRecipient == TargetType.SPECIFIC_TEACHER &&
        _teacherIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a teacher ID')),
      );
      return;
    }

    setState(() {
      _isCreatingActivity = true;
    });

    try {
      final appUser = ref.read(authProvider).value;
      if (appUser == null) return;

      final now = DateTime.now();

      // Determine the specific user ID based on recipient type
      String? specificUserId;
      if (_selectedRecipient == TargetType.SPECIFIC_STUDENT) {
        specificUserId = _studentIdController.text;
      } else if (_selectedRecipient == TargetType.SPECIFIC_TEACHER) {
        specificUserId = _teacherIdController.text;
      }

      // Create an activity for the announcement
      final activity = Activity(
        id: cuid(),
        userId: appUser.id, // The creator's ID
        targetType: _selectedRecipient,
        activityType: ActivityType.announcement,
        activityRefId:
            "", // This would be used to reference other data if needed
        createdAt: now,
        updatedAt: now,
        institutionId: appUser.institutionId,
        title: _titleController.text,
        message: _messageController.text,
        specificUserId: specificUserId,
      );

      await DbService.activitiesCollRef().doc(activity.id).set(activity);

      if (mounted) {
        _titleController.clear();
        _messageController.clear();
        _studentIdController.clear();
        _teacherIdController.clear();
        setState(() {
          _selectedRecipient = TargetType.ALL;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement created successfully!')),
        );

        // Refresh activities list and switch to view tab
        await _loadActivities();
        _tabController.animateTo(0); // Switch to the view tab
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating activity: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingActivity = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'View Announcements'),
            Tab(text: 'Create Announcement'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // View Announcements Tab
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _activities.isEmpty
                  ? const Center(child: Text('No announcements yet'))
                  : ListView.builder(
                      itemCount: _activities.length,
                      itemBuilder: (context, index) {
                        final activity = _activities[index];
                        return ActivityCard(activity: activity);
                      },
                    ),

          // Create Announcement Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter announcement title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Message',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Enter announcement message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 8,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Recipient',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TargetType>(
                      isExpanded: true,
                      value: _selectedRecipient,
                      items: TargetType.values.map((recipient) {
                        return DropdownMenuItem<TargetType>(
                          value: recipient,
                          child: Text(_getRecipientLabel(recipient)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRecipient = value!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedRecipient == TargetType.SPECIFIC_STUDENT) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Student ID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(
                      hintText: 'Enter student ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                if (_selectedRecipient == TargetType.SPECIFIC_TEACHER) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Teacher ID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _teacherIdController,
                    decoration: const InputDecoration(
                      hintText: 'Enter teacher ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _isCreatingActivity ? null : _createActivity,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                    child: _isCreatingActivity
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'CREATE ANNOUNCEMENT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRecipientLabel(TargetType recipient) {
    switch (recipient) {
      case TargetType.ALL:
        return 'All';
      case TargetType.ALL_TEACHERS:
        return 'Teachers';
      case TargetType.ALL_STUDENTS:
        return 'Students';
      case TargetType.SPECIFIC_STUDENT:
        return 'Specific Student';
      case TargetType.SPECIFIC_TEACHER:
        return 'Specific Teacher';
    }
  }
}

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    // Get the title and message from the activity
    final String title = activity.title ?? "Announcement";
    final String message = activity.message ?? "No message provided";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  _getRecipientLabel(activity.targetType),
                  style: TextStyle(
                    color: _getRecipientColor(activity.targetType),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 8),
            Text(
              'Posted on ${DateFormat('MMM dd, yyyy - hh:mm a').format(activity.createdAt)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRecipientLabel(TargetType targetType) {
    switch (targetType) {
      case TargetType.ALL:
        return 'All';
      case TargetType.ALL_TEACHERS:
        return 'Teachers';
      case TargetType.ALL_STUDENTS:
        return 'Students';
      case TargetType.SPECIFIC_STUDENT:
        return 'Specific Student';
      case TargetType.SPECIFIC_TEACHER:
        return 'Specific Teacher';
    }
  }

  Color _getRecipientColor(TargetType targetType) {
    switch (targetType) {
      case TargetType.ALL:
        return Colors.blue;
      case TargetType.ALL_TEACHERS:
        return Colors.green;
      case TargetType.ALL_STUDENTS:
        return Colors.orange;
      case TargetType.SPECIFIC_STUDENT:
        return Colors.purple;
      case TargetType.SPECIFIC_TEACHER:
        return Colors.teal;
    }
  }
}
