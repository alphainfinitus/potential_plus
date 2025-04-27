import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:potential_plus/router/route_names.dart';
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
  initialLocation: RouteNames.home,
  routes: [
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    // Admin routes
    GoRoute(
      path: RouteNames.adminHome,
      builder: (context, state) => const AdminHomeScreen(),
    ),
    GoRoute(
      path: RouteNames.adminEditTimeTable,
      builder: (context, state) => const ClassSelectionScreen(),
    ),
    GoRoute(
      path: RouteNames.adminStudentInfo,
      builder: (context, state) => const AdminStudentInfoScreen(),
    ),
    // Teacher routes
    GoRoute(
      path: RouteNames.teacherHome,
      builder: (context, state) => const TeacherHomeScreen(),
    ),
    GoRoute(
      path: RouteNames.teacherMarkAttendance,
      builder: (context, state) => const TeacherMarkAttendanceScreen(),
    ),
    // Student routes
    GoRoute(
      path: RouteNames.studentHome,
      builder: (context, state) => const StudentHomeScreen(),
    ),
    // Timetable route
    GoRoute(
      path: RouteNames.timetable,
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
