import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/responsive.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/providers/auth_provider/auth_provider.dart';
import 'package:potential_plus/providers/classes_provider/classes_provider.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:intl/intl.dart';

class StudentTimetableScreen extends ConsumerStatefulWidget {
  const StudentTimetableScreen({super.key});

  @override
  ConsumerState<StudentTimetableScreen> createState() =>
      _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends ConsumerState<StudentTimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  final int _currentDay = DateTime.now().weekday - 1;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  final List<IconData> _subjectIcons = [
    Icons.science_outlined,
    Icons.calculate_outlined,
    Icons.language_outlined,
    Icons.history_edu_outlined,
    Icons.fitness_center_outlined,
    Icons.music_note_outlined,
    Icons.palette_outlined,
    Icons.psychology_outlined,
    Icons.code_outlined,
  ];

  // Subject colors mapping
  final Map<String, Color> _subjectColors = {};
  final List<Color> _colorPalette = [
    const Color(0xFF4F6CFF), // Blue
    const Color(0xFFFF7D54), // Orange
    const Color(0xFF48D0B0), // Teal
    const Color(0xFFFFCE4B), // Yellow
    const Color(0xFF9F5CFF), // Purple
    const Color(0xFFFF5C8E), // Pink
    const Color(0xFF5CE1FF), // Light Blue
    const Color(0xFF5CFF95), // Green
    const Color(0xFFFF5C5C), // Red
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _days.length,
      vsync: this,
      initialIndex: _currentDay < _days.length ? _currentDay : 0,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Color _getSubjectColor(String subject) {
    if (!_subjectColors.containsKey(subject)) {
      // Assign a color from palette using modulo to cycle through colors
      _subjectColors[subject] =
          _colorPalette[_subjectColors.length % _colorPalette.length];
    }
    return _subjectColors[subject]!;
  }

  IconData _getSubjectIcon(String subject) {
    // This is a simple way to assign icons - you might want to improve this logic
    final int hashCode = subject.toLowerCase().hashCode.abs();
    return _subjectIcons[hashCode % _subjectIcons.length];
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Map<String, InstitutionClass>? classes =
        ref.watch(classesProvider).value;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFF7F9FC);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const AppBarTitle(title: 'My Schedule'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              // Jump to today's schedule
              final today = DateTime.now().weekday - 1;
              if (today < _days.length) {
                _tabController.animateTo(today);
                _pageController.animateToPage(
                  today,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
        ],
      ),
      body: user.when(
        data: (appUser) {
          if (appUser == null || appUser.classId == null) {
            return _buildEmptyState(
              icon: Icons.class_outlined,
              message: 'No class assigned',
              isError: false,
            );
          }

          if (classes == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final studentClass = classes[appUser.classId];
          if (studentClass == null) {
            return _buildEmptyState(
              icon: Icons.error_outline,
              message: 'Class not found',
              isError: true,
            );
          }

          // Assign colors to subjects for consistency
          _assignSubjectColors(studentClass);

          return Column(
            children: [
              _buildHeader(context, studentClass),
              _buildDateSelector(context),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _days.length,
                  onPageChanged: (index) {
                    if (_tabController.index != index) {
                      _tabController.animateTo(index);
                    }
                  },
                  itemBuilder: (context, index) {
                    return _buildDaySchedule(context, studentClass, index);
                  },
                ),
              ),
            ],
          );
        },
        error: (error, _) => _buildEmptyState(
          icon: Icons.error_outline,
          message: 'Error loading timetable',
          isError: true,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _assignSubjectColors(InstitutionClass studentClass) {
    // Extract all unique subjects
    final subjects = <String>{};
    for (int i = 0; i < 6; i++) {
      final daySchedule = studentClass.timeTable[i.toString()] ?? [];
      for (var period in daySchedule) {
        subjects.add(period.subject);
      }
    }

    // Assign colors to subjects
    int colorIndex = 0;
    for (var subject in subjects) {
      if (!_subjectColors.containsKey(subject)) {
        _subjectColors[subject] =
            _colorPalette[colorIndex % _colorPalette.length];
        colorIndex++;
      }
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required bool isError,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: isError
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: Responsive.getFontSize(context, 20),
              fontWeight: FontWeight.w500,
              color: isError
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (!isError) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(builder: (_) => SomeHelpScreen()),
                // );
              },
              icon: const Icon(Icons.help_outline),
              label: const Text('Get Help'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, InstitutionClass studentClass) {
    final now = DateTime.now();
    final String formattedDate = DateFormat('MMMM d, yyyy').format(now);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal:
            Responsive.getPadding(context, ResponsiveSizes.paddingLarge),
        vertical: Responsive.getPadding(context, ResponsiveSizes.paddingMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 16),
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Class: ${studentClass.name}',
                    style: TextStyle(
                      fontSize: Responsive.getFontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              _buildTimeIndicator(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeIndicator(BuildContext context) {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    // This is a simplified example - you'd want to calculate this based on your school's actual schedule
    final int totalMinutes = currentHour * 60 + currentMinute;
    const int schoolStartMinutes = 8 * 60; // 8:00 AM
    const int schoolEndMinutes = 16 * 60; // 4:00 PM

    double progress = 0.0;
    if (totalMinutes >= schoolStartMinutes &&
        totalMinutes <= schoolEndMinutes) {
      progress = (totalMinutes - schoolStartMinutes) /
          (schoolEndMinutes - schoolStartMinutes);
    } else if (totalMinutes > schoolEndMinutes) {
      progress = 1.0;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            Theme.of(context).colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('h:mm a').format(now),
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: 80,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(
        vertical: Responsive.getMargin(context, ResponsiveSizes.marginMedium),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
        tabs: List.generate(_days.length, (index) {
          // Check if this tab is for today
          final isToday = DateTime.now().weekday - 1 == index;

          return Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: isToday
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    )
                  : null,
              child: Text(
                _days[index],
                style: TextStyle(
                  fontSize: Responsive.getFontSize(context, 15),
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDaySchedule(
      BuildContext context, InstitutionClass studentClass, int dayIndex) {
    final daySchedule = studentClass.timeTable[dayIndex.toString()] ?? [];

    if (daySchedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No classes scheduled',
              style: TextStyle(
                fontSize: Responsive.getFontSize(context, 18),
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal:
            Responsive.getPadding(context, ResponsiveSizes.paddingLarge),
        vertical: Responsive.getPadding(context, ResponsiveSizes.paddingMedium),
      ),
      itemCount: daySchedule.length,
      itemBuilder: (context, periodIndex) {
        final entry =
            periodIndex < daySchedule.length ? daySchedule[periodIndex] : null;

        if (entry == null) {
          return _buildFreePeriodCard(context, periodIndex);
        }

        return _buildClassCard(context, entry, periodIndex);
      },
    );
  }

  Widget _buildClassCard(BuildContext context, dynamic entry, int periodIndex) {
    final subjectColor = _getSubjectColor(entry.subject);
    final subjectIcon = _getSubjectIcon(entry.subject);

    // Sample time slots - you would replace this with actual data
    final List<String> startTimes = [
      '8:00',
      '9:00',
      '10:00',
      '11:15',
      '12:15',
      '1:30',
      '2:30',
      '3:30'
    ];
    final List<String> endTimes = [
      '8:50',
      '9:50',
      '10:50',
      '12:05',
      '1:05',
      '2:20',
      '3:20',
      '4:20'
    ];

    final startTime =
        periodIndex < startTimes.length ? startTimes[periodIndex] : '?';
    final endTime = periodIndex < endTimes.length ? endTimes[periodIndex] : '?';

    return Container(
      margin: EdgeInsets.only(
        bottom: Responsive.getMargin(context, ResponsiveSizes.marginMedium),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                subjectColor.withValues(alpha: 0.15),
                subjectColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: subjectColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(
                      Responsive.getPadding(
                          context, ResponsiveSizes.paddingMedium),
                    ),
                    child: Row(
                      children: [
                        // Time column
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              startTime,
                              style: TextStyle(
                                fontSize: Responsive.getFontSize(context, 14),
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 30,
                              width: 2,
                              decoration: BoxDecoration(
                                color: subjectColor.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              endTime,
                              style: TextStyle(
                                fontSize: Responsive.getFontSize(context, 14),
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Subject details
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: subjectColor.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    subjectIcon,
                                    size: 28,
                                    color: subjectColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      entry.subject,
                                      style: TextStyle(
                                        fontSize:
                                            Responsive.getFontSize(context, 16),
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          entry.teacherId,
                                          style: TextStyle(
                                            fontSize: Responsive.getFontSize(
                                                context, 13),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Room ${100 + ((periodIndex + 1) * (entry.subject.hashCode % 5))}',
                                          style: TextStyle(
                                            fontSize: Responsive.getFontSize(
                                                context, 13),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFreePeriodCard(BuildContext context, int periodIndex) {
    // Sample time slots - you would replace this with actual data
    final List<String> startTimes = [
      '8:00',
      '9:00',
      '10:00',
      '11:15',
      '12:15',
      '1:30',
      '2:30',
      '3:30'
    ];
    final List<String> endTimes = [
      '8:50',
      '9:50',
      '10:50',
      '12:05',
      '1:05',
      '2:20',
      '3:20',
      '4:20'
    ];

    final startTime =
        periodIndex < startTimes.length ? startTimes[periodIndex] : '?';
    final endTime = periodIndex < endTimes.length ? endTimes[periodIndex] : '?';

    return Container(
      margin: EdgeInsets.only(
        bottom: Responsive.getMargin(context, ResponsiveSizes.marginMedium),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Padding(
            padding: EdgeInsets.all(
              Responsive.getPadding(context, ResponsiveSizes.paddingMedium),
            ),
            child: Row(
              children: [
                // Time column
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      startTime,
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 14),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 30,
                      width: 2,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      endTime,
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(context, 14),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Free period content
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.free_breakfast_outlined,
                            size: 28,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Free Period',
                              style: TextStyle(
                                fontSize: Responsive.getFontSize(context, 16),
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Take a break or study time',
                              style: TextStyle(
                                fontSize: Responsive.getFontSize(context, 13),
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
