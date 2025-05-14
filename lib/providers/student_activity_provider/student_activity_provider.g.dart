// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_activity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentActivityNotifierHash() =>
    r'5576b5a51518e8acfc73084272e25b0a029c945b';

/// See also [StudentActivityNotifier].
@ProviderFor(StudentActivityNotifier)
final studentActivityNotifierProvider = AutoDisposeStreamNotifierProvider<
    StudentActivityNotifier, List<Activity>?>.internal(
  StudentActivityNotifier.new,
  name: r'studentActivityNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$studentActivityNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StudentActivityNotifier = AutoDisposeStreamNotifier<List<Activity>?>;
String _$liveStudentActivityNotifierHash() =>
    r'99ab03548386859a40c6cf51983c3b4aeeadd939';

/// See also [LiveStudentActivityNotifier].
@ProviderFor(LiveStudentActivityNotifier)
final liveStudentActivityNotifierProvider = AutoDisposeStreamNotifierProvider<
    LiveStudentActivityNotifier, List<Activity>?>.internal(
  LiveStudentActivityNotifier.new,
  name: r'liveStudentActivityNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$liveStudentActivityNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LiveStudentActivityNotifier
    = AutoDisposeStreamNotifier<List<Activity>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
