import 'package:go_router/go_router.dart';
import 'package:potential_plus/constants/route_paths.dart';
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
import 'package:potential_plus/screens/student/student_attendance_screen.dart';
import 'package:potential_plus/screens/student/student_results_screen.dart';
import 'package:potential_plus/screens/student/student_events_screen.dart';
import 'package:potential_plus/screens/student/student_feedback_screen.dart';
import 'package:potential_plus/screens/student/student_timetable_screen.dart';
import 'package:potential_plus/screens/teacher/teacher_home_screen.dart';
import 'package:potential_plus/screens/teacher/teacher_mark_attendance/teacher_mark_attendance.dart';

final router = GoRouter(
  initialLocation: RoutePaths.root,
  routes: [
    // Root route
    GoRoute(
      path: RoutePaths.root,
      builder: (context, state) => const HomeScreen(),
    ),

    // Auth routes
    GoRoute(
      path: RoutePaths.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RoutePaths.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: RoutePaths.profile,
      builder: (context, state) => const ProfileScreen(),
    ),

    // Admin routes
    GoRoute(
      path: RoutePaths.admin,
      builder: (context, state) => const AdminHomeScreen(),
    ),
    GoRoute(
      path: RoutePaths.adminEditTimeTable,
      builder: (context, state) => const AdminEditTimeTableScreen(),
    ),
    GoRoute(
      path: RoutePaths.adminStudentInfo,
      builder: (context, state) => const AdminStudentInfoScreen(),
    ),
    GoRoute(
      path: RoutePaths.adminManageClasses,
      builder: (context, state) => const AdminManageClassesScreen(),
    ),
    GoRoute(
      path: RoutePaths.adminManageStudents,
      builder: (context, state) => const AdminManageStudentsScreen(),
    ),
    GoRoute(
      path: RoutePaths.adminManageTeachers,
      builder: (context, state) => const AdminManageTeachersScreen(),
    ),

    // Teacher routes
    GoRoute(
      path: RoutePaths.teacher,
      builder: (context, state) => const TeacherHomeScreen(),
    ),
    GoRoute(
      path: RoutePaths.teacherMarkAttendance,
      builder: (context, state) => const TeacherMarkAttendanceScreen(),
    ),

    // Student routes
    GoRoute(
      path: RoutePaths.student,
      builder: (context, state) => const StudentHomeScreen(),
    ),
    GoRoute(
      path: RoutePaths.studentAttendance,
      builder: (context, state) => const StudentAttendanceScreen(),
    ),
    GoRoute(
      path: RoutePaths.studentResults,
      builder: (context, state) => const StudentResultsScreen(),
    ),
    GoRoute(
      path: RoutePaths.studentEvents,
      builder: (context, state) => const StudentEventsScreen(),
    ),
    GoRoute(
      path: RoutePaths.studentFeedback,
      builder: (context, state) => const StudentFeedbackScreen(),
    ),
    GoRoute(
      path: RoutePaths.studentTimetable,
      builder: (context, state) => const StudentTimetableScreen(),
    ),
  ],
);
