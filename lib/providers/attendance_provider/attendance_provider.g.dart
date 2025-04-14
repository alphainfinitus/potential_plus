// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentAttendanceHash() => r'423cd1ab821ace2c0fab90da3dfd37bc6d20ece8';

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
String _$attendanceStatsHash() => r'b6d761d25de82c81b9fcb35c42b5c33484b34234';

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
String _$attendanceNotifierHash() =>
    r'3f6a12d77c357a4269ccb842931540c1917e885e';

/// See also [AttendanceNotifier].
@ProviderFor(AttendanceNotifier)
final attendanceNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AttendanceNotifier, void>.internal(
  AttendanceNotifier.new,
  name: r'attendanceNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$attendanceNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AttendanceNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
