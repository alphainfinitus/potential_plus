// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_activity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentActivityNotifierHash() =>
    r'2e25ed6b6539d1b2b3442807b4f9f1af366051a2';

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
    r'4d1f4cba00006f49841468cd753cb96f94d9b876';

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
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
