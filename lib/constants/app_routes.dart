import 'package:flutter/material.dart';
import 'package:potential_plus/screens/admin/admin_edit_time_table_screen/admin_edit_time_table_screen.dart';
import 'package:potential_plus/screens/admin/admin_home_screen.dart';
import 'package:potential_plus/screens/admin/admin_manage_classes_screen.dart';
import 'package:potential_plus/screens/admin/admin_manage_students_screen.dart';
import 'package:potential_plus/screens/admin/admin_manage_teachers_screen.dart';
import 'package:potential_plus/screens/admin/admin_student_info_screen/admin_student_info_screen.dart';
import 'package:potential_plus/screens/auth/forgot_password_screen/forgot_password_screen.dart';
import 'package:potential_plus/screens/auth/login_screen/login_screen.dart';
import 'package:potential_plus/screens/home_screen.dart';
import 'package:potential_plus/screens/profile/profile_screen.dart';
import 'package:potential_plus/screens/student/student_home_screen.dart';
import 'package:potential_plus/screens/teacher/teacher_home_screen.dart';
import 'package:potential_plus/screens/teacher/teacher_mark_attendance/teacher_mark_attendance.dart';
import 'package:potential_plus/screens/student/student_profile_screen.dart';
import 'package:potential_plus/screens/admin/admin_profile_screen.dart';
import 'package:potential_plus/screens/student/student_attendance_screen.dart';
import 'package:potential_plus/screens/student/student_results_screen.dart';
import 'package:potential_plus/screens/student/student_events_screen.dart';
import 'package:potential_plus/screens/student/student_feedback_screen.dart';
import 'package:potential_plus/screens/student/student_timetable_screen.dart';
import 'package:potential_plus/screens/teacher/teacher_dashboard_screen.dart';

enum AppRoutes {
  home,
  profile,
  studentProfile,
  adminProfile,

  //auth
  login,
  forgotPassword,

  //admin routes
  adminHomeScreen,
  adminEditTimeTable,
  adminStudentInfo,
  adminManageClasses,
  adminManageStudents,
  adminManageTeachers,

  //teacher routes
  teacherHomeScreen,
  teacherMarkAttendance,
  teacherDashboard,

  //student routes
  studentHomeScreen,
  studentTimetable,
  studentAttendance,
  studentResults,
  studentEvents,
  studentFeedback,
}

extension AppRoutesExtension on AppRoutes {
  String get path {
    switch (this) {
      case AppRoutes.home:
        return '/';
      case AppRoutes.profile:
        return '/profile';
      case AppRoutes.studentProfile:
        return '/student/profile';
      case AppRoutes.adminProfile:
        return '/admin/profile';

      case AppRoutes.login:
        return '/login';
      case AppRoutes.forgotPassword:
        return '/forgot-password';

      case AppRoutes.adminHomeScreen:
        return '/admin';
      case AppRoutes.adminEditTimeTable:
        return '/admin/edit-time-table';
      case AppRoutes.adminStudentInfo:
        return '/admin/student-info';
      case AppRoutes.adminManageClasses:
        return '/admin/manage-classes';
      case AppRoutes.adminManageStudents:
        return '/admin/manage-students';
      case AppRoutes.adminManageTeachers:
        return '/admin/manage-teachers';

      case AppRoutes.teacherHomeScreen:
        return '/teacher';
      case AppRoutes.teacherMarkAttendance:
        return '/teacher/mark-attendance';
      case AppRoutes.teacherDashboard:
        return '/teacher/dashboard';

      case AppRoutes.studentHomeScreen:
        return '/student';
      case AppRoutes.studentTimetable:
        return '/student/timetable';
      case AppRoutes.studentAttendance:
        return '/student/attendance';
      case AppRoutes.studentResults:
        return '/student/results';
      case AppRoutes.studentEvents:
        return '/student/events';
      case AppRoutes.studentFeedback:
        return '/student/feedback';

    }
  }
}

final Map<String, WidgetBuilder> appRoutesMap = {
  AppRoutes.home.path: (context) => const HomeScreen(),
  AppRoutes.profile.path: (context) => const ProfileScreen(),
  AppRoutes.studentProfile.path: (context) => const StudentProfileScreen(),
  AppRoutes.adminProfile.path: (context) => const AdminProfileScreen(),
  AppRoutes.login.path: (context) => const LoginScreen(),
  AppRoutes.forgotPassword.path: (context) => const ForgotPasswordScreen(),
  AppRoutes.adminHomeScreen.path: (context) => const AdminHomeScreen(),
  AppRoutes.adminEditTimeTable.path: (context) =>
      const AdminEditTimeTableScreen(),
  AppRoutes.adminStudentInfo.path: (context) => const AdminStudentInfoScreen(),
  AppRoutes.adminManageClasses.path: (context) =>
      const AdminManageClassesScreen(),
  AppRoutes.adminManageStudents.path: (context) =>
      const AdminManageStudentsScreen(),
  AppRoutes.adminManageTeachers.path: (context) =>
      const AdminManageTeachersScreen(),
  AppRoutes.teacherHomeScreen.path: (context) => const TeacherHomeScreen(),
  AppRoutes.teacherMarkAttendance.path: (context) =>
      const TeacherMarkAttendanceScreen(),
  AppRoutes.teacherDashboard.path: (context) => const TeacherDashboardScreen(),
  AppRoutes.studentHomeScreen.path: (context) => const StudentHomeScreen(),
  AppRoutes.studentTimetable.path: (context) => const StudentTimetableScreen(),
  AppRoutes.studentAttendance.path: (context) =>
      const StudentAttendanceScreen(),
  AppRoutes.studentResults.path: (context) => const StudentResultsScreen(),
  AppRoutes.studentEvents.path: (context) => const StudentEventsScreen(),
  AppRoutes.studentFeedback.path: (context) => const StudentFeedbackScreen(),
};
