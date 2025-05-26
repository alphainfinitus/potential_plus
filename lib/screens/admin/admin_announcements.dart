import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/models/activity.dart';
import 'package:potential_plus/constants/activity_type.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/services/db_service.dart';
import 'package:intl/intl.dart';
import 'package:cuid2/cuid2.dart';

enum RecipientType {
  all,
  teachers,
  students,
  specificStudent,
}

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
  RecipientType _selectedRecipient = RecipientType.all;
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
    super.dispose();
  }

  Future<void> _loadActivities() async {
    final appUser = ref.read(authProvider).value;
    if (appUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final activities =
          await DbService.getInstitutionAnnouncements(appUser.institutionId);

      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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

    if (_selectedRecipient == RecipientType.specificStudent &&
        _studentIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a student ID')),
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

      // Create an activity for the announcement
      final activity = Activity(
        id: cuid(),
        userId: _selectedRecipient == RecipientType.specificStudent
            ? _studentIdController.text
            : appUser.id,
        activityType: ActivityType.attendance,
        activityRefId:
            "", // This would be used to reference other data if needed
        createdAt: now,
        updatedAt: now,
      );

      // In a real implementation, you would also save the title, message, and target in a separate collection
      // or add these as custom fields to the Activity document in Firestore

      // Save the activity to Firestore
      await DbService.activitiesCollRef().doc(activity.id).set(activity);

      if (mounted) {
        // Clear form fields
        _titleController.clear();
        _messageController.clear();
        _studentIdController.clear();
        setState(() {
          _selectedRecipient = RecipientType.all;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement created successfully!')),
        );

        // Refresh activities list and switch to view tab
        _loadActivities();
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

  String _getRecipientLabel(RecipientType recipient) {
    switch (recipient) {
      case RecipientType.all:
        return 'All';
      case RecipientType.teachers:
        return 'Teachers';
      case RecipientType.students:
        return 'Students';
      case RecipientType.specificStudent:
        return 'Specific Student';
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
                    child: DropdownButton<RecipientType>(
                      isExpanded: true,
                      value: _selectedRecipient,
                      items: RecipientType.values.map((recipient) {
                        return DropdownMenuItem<RecipientType>(
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
                if (_selectedRecipient == RecipientType.specificStudent) ...[
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
}

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    // In a real implementation, you would extract the title and message from a related document or metadata
    final String title = "Announcement";
    final String message = "Activity message";

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
                  _getRecipientLabel(activity),
                  style: TextStyle(
                    color: _getRecipientColor(activity),
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

  String _getRecipientLabel(Activity activity) {
    // In a real implementation, you would determine the recipient type from activity metadata
    return "All";
  }

  Color _getRecipientColor(Activity activity) {
    // In a real implementation, you would determine the color based on recipient type
    return Colors.blue;
  }
}
