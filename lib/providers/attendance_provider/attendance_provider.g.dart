// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentAttendanceHash() => r'eab809fdc9d31549ddab6c6878264b360696e875';

/// See also [studentAttendance].
@ProviderFor(studentAttendance)
final studentAttendanceProvider =
    AutoDisposeFutureProvider<Map<DateTime, List<Attendance>>>.internal(
  studentAttendance,
  name: r'studentAttendanceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$studentAttendanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentAttendanceRef
    = AutoDisposeFutureProviderRef<Map<DateTime, List<Attendance>>>;
String _$attendanceStatsHash() => r'ccecd9c607272160d345a965ed6947eb422e84f8';

/// See also [attendanceStats].
@ProviderFor(attendanceStats)
final attendanceStatsProvider =
    AutoDisposeFutureProvider<Map<String, int>>.internal(
  attendanceStats,
  name: r'attendanceStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$attendanceStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttendanceStatsRef = AutoDisposeFutureProviderRef<Map<String, int>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
