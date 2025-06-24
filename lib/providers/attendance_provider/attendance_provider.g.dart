// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attendanceWatcherHash() => r'ceb7eb753b5af2a4f97b7455306748b3c134b6d0';

/// See also [attendanceWatcher].
@ProviderFor(attendanceWatcher)
final attendanceWatcherProvider = AutoDisposeProvider<void>.internal(
  attendanceWatcher,
  name: r'attendanceWatcherProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$attendanceWatcherHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttendanceWatcherRef = AutoDisposeProviderRef<void>;
String _$classTimetableHash() => r'1d18ab0d487bd634c0137cc7f69750e62b51b3c0';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [classTimetable].
@ProviderFor(classTimetable)
const classTimetableProvider = ClassTimetableFamily();

/// See also [classTimetable].
class ClassTimetableFamily extends Family<AsyncValue<TimeTable?>> {
  /// See also [classTimetable].
  const ClassTimetableFamily();

  /// See also [classTimetable].
  ClassTimetableProvider call(
    String classId,
  ) {
    return ClassTimetableProvider(
      classId,
    );
  }

  @override
  ClassTimetableProvider getProviderOverride(
    covariant ClassTimetableProvider provider,
  ) {
    return call(
      provider.classId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'classTimetableProvider';
}

/// See also [classTimetable].
class ClassTimetableProvider extends AutoDisposeFutureProvider<TimeTable?> {
  /// See also [classTimetable].
  ClassTimetableProvider(
    String classId,
  ) : this._internal(
          (ref) => classTimetable(
            ref as ClassTimetableRef,
            classId,
          ),
          from: classTimetableProvider,
          name: r'classTimetableProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$classTimetableHash,
          dependencies: ClassTimetableFamily._dependencies,
          allTransitiveDependencies:
              ClassTimetableFamily._allTransitiveDependencies,
          classId: classId,
        );

  ClassTimetableProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
  }) : super.internal();

  final String classId;

  @override
  Override overrideWith(
    FutureOr<TimeTable?> Function(ClassTimetableRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClassTimetableProvider._internal(
        (ref) => create(ref as ClassTimetableRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TimeTable?> createElement() {
    return _ClassTimetableProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClassTimetableProvider && other.classId == classId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ClassTimetableRef on AutoDisposeFutureProviderRef<TimeTable?> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _ClassTimetableProviderElement
    extends AutoDisposeFutureProviderElement<TimeTable?>
    with ClassTimetableRef {
  _ClassTimetableProviderElement(super.provider);

  @override
  String get classId => (origin as ClassTimetableProvider).classId;
}

String _$classStudentsHash() => r'9c284b0a396c5d8db8389116f6770d3e652e1091';

/// See also [classStudents].
@ProviderFor(classStudents)
const classStudentsProvider = ClassStudentsFamily();

/// See also [classStudents].
class ClassStudentsFamily extends Family<AsyncValue<List<AppUser>>> {
  /// See also [classStudents].
  const ClassStudentsFamily();

  /// See also [classStudents].
  ClassStudentsProvider call(
    String classId,
  ) {
    return ClassStudentsProvider(
      classId,
    );
  }

  @override
  ClassStudentsProvider getProviderOverride(
    covariant ClassStudentsProvider provider,
  ) {
    return call(
      provider.classId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'classStudentsProvider';
}

/// See also [classStudents].
class ClassStudentsProvider extends AutoDisposeFutureProvider<List<AppUser>> {
  /// See also [classStudents].
  ClassStudentsProvider(
    String classId,
  ) : this._internal(
          (ref) => classStudents(
            ref as ClassStudentsRef,
            classId,
          ),
          from: classStudentsProvider,
          name: r'classStudentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$classStudentsHash,
          dependencies: ClassStudentsFamily._dependencies,
          allTransitiveDependencies:
              ClassStudentsFamily._allTransitiveDependencies,
          classId: classId,
        );

  ClassStudentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
  }) : super.internal();

  final String classId;

  @override
  Override overrideWith(
    FutureOr<List<AppUser>> Function(ClassStudentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClassStudentsProvider._internal(
        (ref) => create(ref as ClassStudentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AppUser>> createElement() {
    return _ClassStudentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClassStudentsProvider && other.classId == classId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ClassStudentsRef on AutoDisposeFutureProviderRef<List<AppUser>> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _ClassStudentsProviderElement
    extends AutoDisposeFutureProviderElement<List<AppUser>>
    with ClassStudentsRef {
  _ClassStudentsProviderElement(super.provider);

  @override
  String get classId => (origin as ClassStudentsProvider).classId;
}

String _$lectureAttendanceHash() => r'c7ec54a1bcdf4112d4db171c0aa37e1ea3ed3e56';

/// See also [lectureAttendance].
@ProviderFor(lectureAttendance)
const lectureAttendanceProvider = LectureAttendanceFamily();

/// See also [lectureAttendance].
class LectureAttendanceFamily extends Family<AsyncValue<Map<String, bool>>> {
  /// See also [lectureAttendance].
  const LectureAttendanceFamily();

  /// See also [lectureAttendance].
  LectureAttendanceProvider call(
    AttendanceParams params,
  ) {
    return LectureAttendanceProvider(
      params,
    );
  }

  @override
  LectureAttendanceProvider getProviderOverride(
    covariant LectureAttendanceProvider provider,
  ) {
    return call(
      provider.params,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'lectureAttendanceProvider';
}

/// See also [lectureAttendance].
class LectureAttendanceProvider
    extends AutoDisposeFutureProvider<Map<String, bool>> {
  /// See also [lectureAttendance].
  LectureAttendanceProvider(
    AttendanceParams params,
  ) : this._internal(
          (ref) => lectureAttendance(
            ref as LectureAttendanceRef,
            params,
          ),
          from: lectureAttendanceProvider,
          name: r'lectureAttendanceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$lectureAttendanceHash,
          dependencies: LectureAttendanceFamily._dependencies,
          allTransitiveDependencies:
              LectureAttendanceFamily._allTransitiveDependencies,
          params: params,
        );

  LectureAttendanceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.params,
  }) : super.internal();

  final AttendanceParams params;

  @override
  Override overrideWith(
    FutureOr<Map<String, bool>> Function(LectureAttendanceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LectureAttendanceProvider._internal(
        (ref) => create(ref as LectureAttendanceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        params: params,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, bool>> createElement() {
    return _LectureAttendanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LectureAttendanceProvider && other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LectureAttendanceRef on AutoDisposeFutureProviderRef<Map<String, bool>> {
  /// The parameter `params` of this provider.
  AttendanceParams get params;
}

class _LectureAttendanceProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, bool>>
    with LectureAttendanceRef {
  _LectureAttendanceProviderElement(super.provider);

  @override
  AttendanceParams get params => (origin as LectureAttendanceProvider).params;
}

String _$attendanceControllerHash() =>
    r'cd1da314e38d8ac34a0f23c0e8c22c06b2505fdf';

/// See also [attendanceController].
@ProviderFor(attendanceController)
const attendanceControllerProvider = AttendanceControllerFamily();

/// See also [attendanceController].
class AttendanceControllerFamily extends Family<AttendanceController?> {
  /// See also [attendanceController].
  const AttendanceControllerFamily();

  /// See also [attendanceController].
  AttendanceControllerProvider call(
    AttendanceParams params,
  ) {
    return AttendanceControllerProvider(
      params,
    );
  }

  @override
  AttendanceControllerProvider getProviderOverride(
    covariant AttendanceControllerProvider provider,
  ) {
    return call(
      provider.params,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'attendanceControllerProvider';
}

/// See also [attendanceController].
class AttendanceControllerProvider
    extends AutoDisposeProvider<AttendanceController?> {
  /// See also [attendanceController].
  AttendanceControllerProvider(
    AttendanceParams params,
  ) : this._internal(
          (ref) => attendanceController(
            ref as AttendanceControllerRef,
            params,
          ),
          from: attendanceControllerProvider,
          name: r'attendanceControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$attendanceControllerHash,
          dependencies: AttendanceControllerFamily._dependencies,
          allTransitiveDependencies:
              AttendanceControllerFamily._allTransitiveDependencies,
          params: params,
        );

  AttendanceControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.params,
  }) : super.internal();

  final AttendanceParams params;

  @override
  Override overrideWith(
    AttendanceController? Function(AttendanceControllerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AttendanceControllerProvider._internal(
        (ref) => create(ref as AttendanceControllerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        params: params,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<AttendanceController?> createElement() {
    return _AttendanceControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttendanceControllerProvider && other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AttendanceControllerRef on AutoDisposeProviderRef<AttendanceController?> {
  /// The parameter `params` of this provider.
  AttendanceParams get params;
}

class _AttendanceControllerProviderElement
    extends AutoDisposeProviderElement<AttendanceController?>
    with AttendanceControllerRef {
  _AttendanceControllerProviderElement(super.provider);

  @override
  AttendanceParams get params =>
      (origin as AttendanceControllerProvider).params;
}

String _$selectedClassHash() => r'9a73676be2ba9e1f6d74a047fa039c6be65e9963';

/// See also [SelectedClass].
@ProviderFor(SelectedClass)
final selectedClassProvider =
    AutoDisposeNotifierProvider<SelectedClass, InstitutionClass?>.internal(
  SelectedClass.new,
  name: r'selectedClassProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedClassHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedClass = AutoDisposeNotifier<InstitutionClass?>;
String _$selectedDateHash() => r'cd58c984f6e117508d5f0214769b976e0b808be9';

/// See also [SelectedDate].
@ProviderFor(SelectedDate)
final selectedDateProvider =
    AutoDisposeNotifierProvider<SelectedDate, DateTime>.internal(
  SelectedDate.new,
  name: r'selectedDateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$selectedDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedDate = AutoDisposeNotifier<DateTime>;
String _$selectedLectureHash() => r'ebde45eede8921111190f6e057f7b92df07a8582';

/// See also [SelectedLecture].
@ProviderFor(SelectedLecture)
final selectedLectureProvider =
    AutoDisposeNotifierProvider<SelectedLecture, TimetableEntry?>.internal(
  SelectedLecture.new,
  name: r'selectedLectureProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedLectureHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedLecture = AutoDisposeNotifier<TimetableEntry?>;
String _$attendanceStateHash() => r'0774b39d4e2cec3f74ceaba69eee5593b7f90bf7';

/// See also [AttendanceState].
@ProviderFor(AttendanceState)
final attendanceStateProvider =
    AutoDisposeNotifierProvider<AttendanceState, Map<String, bool>>.internal(
  AttendanceState.new,
  name: r'attendanceStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$attendanceStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AttendanceState = AutoDisposeNotifier<Map<String, bool>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
