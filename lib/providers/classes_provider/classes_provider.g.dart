// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$classesHash() => r'd77777adf0df5a786fb8f202b0062cb88bc9484d';

/// See also [classes].
@ProviderFor(classes)
final classesProvider =
    AutoDisposeFutureProvider<List<InstitutionClass>?>.internal(
  classes,
  name: r'classesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$classesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClassesRef = AutoDisposeFutureProviderRef<List<InstitutionClass>?>;
String _$classStudentsHash() => r'6acccd9faf9f8bd6d7f53f22dca749861b1a6985';

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

/// See also [classStudents].
@ProviderFor(classStudents)
const classStudentsProvider = ClassStudentsFamily();

/// See also [classStudents].
class ClassStudentsFamily extends Family<AsyncValue<Map<String, AppUser>>> {
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
class ClassStudentsProvider
    extends AutoDisposeFutureProvider<Map<String, AppUser>> {
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
    FutureOr<Map<String, AppUser>> Function(ClassStudentsRef provider) create,
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
  AutoDisposeFutureProviderElement<Map<String, AppUser>> createElement() {
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
mixin ClassStudentsRef on AutoDisposeFutureProviderRef<Map<String, AppUser>> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _ClassStudentsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, AppUser>>
    with ClassStudentsRef {
  _ClassStudentsProviderElement(super.provider);

  @override
  String get classId => (origin as ClassStudentsProvider).classId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
