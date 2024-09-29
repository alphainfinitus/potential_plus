import 'package:flutter/material.dart';
import 'package:potential_plus/screens/admin/admin_edit_time_table_screen/admin_edit_time_table_screen.dart';
import 'package:potential_plus/screens/admin/admin_home_screen.dart';
import 'package:potential_plus/screens/auth/forgot_password_screen/forgot_password_screen.dart';
import 'package:potential_plus/screens/auth/login_screen/login_screen.dart';
import 'package:potential_plus/screens/home_screen.dart';
import 'package:potential_plus/screens/profile/profile_screen.dart';
import 'package:potential_plus/screens/student/student_home_screen.dart';
import 'package:potential_plus/screens/teacher/teacher_home_screen.dart';
import 'package:potential_plus/screens/teacher/teacher_mark_attendance/teacher_mark_attendance.dart';

enum AppRoutes {
  home,
  profile,

  //auth
  login,
  forgotPassword,

  //admin routes
  adminHomeScreen,
  adminEditTimeTable,

  //student routes
  studentHomeScreen,

  //teacher routes
  teacherHomeScreen,
  teacherMarkAttendance
}

extension AppRoutesExtension on AppRoutes {
  String get path {
    switch (this) {
      case AppRoutes.home:
        return '/';
      case AppRoutes.profile:
        return '/profile';

      case AppRoutes.login:
        return '/login';
      case AppRoutes.forgotPassword:
        return '/forgot-password';

      case AppRoutes.adminHomeScreen:
        return '/admin/';
      case AppRoutes.adminEditTimeTable:
        return '/admin/edit-time-table';

      case AppRoutes.studentHomeScreen:
        return '/student/';

      case AppRoutes.teacherHomeScreen:
        return '/teacher/';
      case AppRoutes.teacherMarkAttendance:
        return '/teacher/mark-attendance';

      default:
        return '/';
    }
  }
}

final Map<String, WidgetBuilder> appRoutesMap = {
  AppRoutes.home.path: (context) => const HomeScreen(),
  AppRoutes.profile.path: (context) => const ProfileScreen(),

  AppRoutes.login.path: (context) => const LoginScreen(),
  AppRoutes.forgotPassword.path: (context) => const ForgotPasswordScreen(),

  AppRoutes.adminHomeScreen.path: (context) => const AdminHomeScreen(),
  AppRoutes.adminEditTimeTable.path: (context) => const AdminEditTimeTableScreen(),

  AppRoutes.studentHomeScreen.path: (context) => const StudentHomeScreen(),

  AppRoutes.teacherHomeScreen.path: (context) => const TeacherHomeScreen(),
  AppRoutes.teacherMarkAttendance.path: (context) => const TeacherMarkAttendanceScreen(),
};