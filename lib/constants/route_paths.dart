class RoutePaths {
  // Root
  static const String root = '/';

  // Auth
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String profile = '/profile';

  // Admin
  static const String admin = '/admin';
  static const String adminEditTimeTable = '$admin/edit-time-table';
  static const String adminStudentInfo = '$admin/student-info';
  static const String adminManageClasses = '$admin/manage-classes';
  static const String adminManageStudents = '$admin/manage-students';
  static const String adminManageTeachers = '$admin/manage-teachers';

  // Teacher
  static const String teacher = '/teacher';
  static const String teacherMarkAttendance = '$teacher/mark-attendance';

  // Student
  static const String student = '/student';
  static const String studentAttendance = '$student/attendance';
  static const String studentResults = '$student/results';
  static const String studentEvents = '$student/events';
  static const String studentFeedback = '$student/feedback';
  static const String studentTimetable = '/student/timetable';
} 