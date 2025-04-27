import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/models/time_table.dart';
import 'package:potential_plus/screens/admin/admin_home_screen.dart';
import 'package:potential_plus/screens/admin/admin_student_info_screen/admin_student_info_screen.dart';
import 'package:potential_plus/screens/auth/forgot_password_screen/forgot_password_screen.dart';
import 'package:potential_plus/screens/auth/login_screen/login_screen.dart';
import 'package:potential_plus/screens/home_screen.dart';
import 'package:potential_plus/screens/profile/profile_screen.dart';
import 'package:potential_plus/screens/student/student_home_screen.dart';
import 'package:potential_plus/screens/teacher/teacher_home_screen.dart';
import 'package:potential_plus/screens/teacher/teacher_mark_attendance/teacher_mark_attendance.dart';
import 'package:potential_plus/screens/timetable/class_selection_screen.dart';
import 'package:potential_plus/screens/timetable/timetable.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    // Admin routes
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminHomeScreen(),
    ),
    GoRoute(
      path: '/admin/edit-time-table',
      builder: (context, state) => const ClassSelectionScreen(),
    ),
    GoRoute(
      path: '/admin/student-info',
      builder: (context, state) => const AdminStudentInfoScreen(),
    ),
    // Teacher routes
    GoRoute(
      path: '/teacher',
      builder: (context, state) => const TeacherHomeScreen(),
    ),
    GoRoute(
      path: '/teacher/mark-attendance',
      builder: (context, state) => const TeacherMarkAttendanceScreen(),
    ),
    // Student routes
    GoRoute(
      path: '/student',
      builder: (context, state) => const StudentHomeScreen(),
    ),
    // Timetable route
    GoRoute(
      path: '/timetable',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return TimetablePage(
          timeTable: extra['timeTable'] as TimeTable,
          classId: extra['classId'] as String,
        );
      },
    ),
  ],
);
