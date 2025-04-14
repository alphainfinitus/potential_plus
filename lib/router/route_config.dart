import 'package:go_router/go_router.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/screens/admin/admin_edit_time_table_screen/admin_edit_time_table_screen.dart';
import 'package:potential_plus/screens/admin/admin_home_screen.dart';
import 'package:potential_plus/screens/admin/admin_manage_classes_screen.dart';
import 'package:potential_plus/screens/admin/admin_manage_students_screen.dart';
import 'package:potential_plus/screens/admin/admin_manage_teachers_screen.dart';
import 'package:potential_plus/screens/admin/admin_profile_screen.dart';
import 'package:potential_plus/screens/admin/admin_student_info_screen/admin_student_info_screen.dart';
import 'package:potential_plus/screens/auth/forgot_password_screen/forgot_password_screen.dart';
import 'package:potential_plus/screens/auth/login_screen/login_screen.dart';
import 'package:potential_plus/screens/home_screen.dart';
import 'package:potential_plus/screens/profile/profile_screen.dart';
import 'package:potential_plus/screens/student/student_attendance_screen.dart';
import 'package:potential_plus/screens/student/student_events_screen.dart';
import 'package:potential_plus/screens/student/student_feedback_screen.dart';
import 'package:potential_plus/screens/student/student_home_screen.dart';
import 'package:potential_plus/screens/student/student_profile_screen.dart';
import 'package:potential_plus/screens/student/student_results_screen.dart';
import 'package:potential_plus/screens/student/student_timetable_screen.dart';
import 'package:potential_plus/screens/teacher/teacher_dashboard_screen.dart';
import 'package:potential_plus/screens/teacher/teacher_home_screen.dart';
import 'package:potential_plus/screens/teacher/teacher_mark_attendance/teacher_mark_attendance.dart';

final router = GoRouter(
  initialLocation: AppRoutes.home.path,
  routes: [
    // Root route
    GoRoute(
      path: AppRoutes.home.path,
      builder: (context, state) => const HomeScreen(),
    ),

    // Auth routes
    GoRoute(
      path: AppRoutes.login.path,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword.path,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile.path,
      builder: (context, state) => const ProfileScreen(),
    ),

    // Admin routes
    GoRoute(
      path: AppRoutes.adminHomeScreen.path,
      builder: (context, state) => const AdminHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminProfile.path,
      builder: (context, state) => const AdminProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminEditTimeTable.path,
      builder: (context, state) => const AdminEditTimeTableScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminStudentInfo.path,
      builder: (context, state) => const AdminStudentInfoScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminManageClasses.path,
      builder: (context, state) => const AdminManageClassesScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminManageStudents.path,
      builder: (context, state) => const AdminManageStudentsScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminManageTeachers.path,
      builder: (context, state) => const AdminManageTeachersScreen(),
    ),

    // Teacher routes
    GoRoute(
      path: AppRoutes.teacherHomeScreen.path,
      builder: (context, state) => const TeacherHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.teacherMarkAttendance.path,
      builder: (context, state) => const TeacherMarkAttendanceScreen(),
    ),
    GoRoute(
      path: AppRoutes.teacherDashboard.path,
      builder: (context, state) => const TeacherDashboardScreen(),
    ),

    // Student routes
    GoRoute(
      path: AppRoutes.studentHomeScreen.path,
      builder: (context, state) => const StudentHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.studentProfile.path,
      builder: (context, state) => const StudentProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.studentTimetable.path,
      builder: (context, state) => const StudentTimetableScreen(),
    ),
    GoRoute(
      path: AppRoutes.studentAttendance.path,
      builder: (context, state) => const StudentAttendanceScreen(),
    ),
    GoRoute(
      path: AppRoutes.studentResults.path,
      builder: (context, state) => const StudentResultsScreen(),
    ),
    GoRoute(
      path: AppRoutes.studentEvents.path,
      builder: (context, state) => const StudentEventsScreen(),
    ),
    GoRoute(
      path: AppRoutes.studentFeedback.path,
      builder: (context, state) => const StudentFeedbackScreen(),
    ),
  ],
);
