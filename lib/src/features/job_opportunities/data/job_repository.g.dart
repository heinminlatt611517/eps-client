// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jobRepositoryHash() => r'da94a2fd1c5e5d003b626b6bc382510829e6ec9b';

/// See also [jobRepository].
@ProviderFor(jobRepository)
final jobRepositoryProvider = AutoDisposeProvider<JobRepository>.internal(
  jobRepository,
  name: r'jobRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$jobRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef JobRepositoryRef = AutoDisposeProviderRef<JobRepository>;
String _$fetchAllJobsHash() => r'7225452b9cbc638314be04a23cd748bbec901a03';

/// See also [fetchAllJobs].
@ProviderFor(fetchAllJobs)
final fetchAllJobsProvider = AutoDisposeFutureProvider<JobsResponse>.internal(
  fetchAllJobs,
  name: r'fetchAllJobsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fetchAllJobsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FetchAllJobsRef = AutoDisposeFutureProviderRef<JobsResponse>;
String _$fetchJobDetailByIdHash() =>
    r'b3e256f2fe52744dd32d8c9c76f32e23318dbe51';

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

/// See also [fetchJobDetailById].
@ProviderFor(fetchJobDetailById)
const fetchJobDetailByIdProvider = FetchJobDetailByIdFamily();

/// See also [fetchJobDetailById].
class FetchJobDetailByIdFamily extends Family<AsyncValue<JobDetailResponse>> {
  /// See also [fetchJobDetailById].
  const FetchJobDetailByIdFamily();

  /// See also [fetchJobDetailById].
  FetchJobDetailByIdProvider call({required String id}) {
    return FetchJobDetailByIdProvider(id: id);
  }

  @override
  FetchJobDetailByIdProvider getProviderOverride(
    covariant FetchJobDetailByIdProvider provider,
  ) {
    return call(id: provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fetchJobDetailByIdProvider';
}

/// See also [fetchJobDetailById].
class FetchJobDetailByIdProvider
    extends AutoDisposeFutureProvider<JobDetailResponse> {
  /// See also [fetchJobDetailById].
  FetchJobDetailByIdProvider({required String id})
    : this._internal(
        (ref) => fetchJobDetailById(ref as FetchJobDetailByIdRef, id: id),
        from: fetchJobDetailByIdProvider,
        name: r'fetchJobDetailByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fetchJobDetailByIdHash,
        dependencies: FetchJobDetailByIdFamily._dependencies,
        allTransitiveDependencies:
            FetchJobDetailByIdFamily._allTransitiveDependencies,
        id: id,
      );

  FetchJobDetailByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<JobDetailResponse> Function(FetchJobDetailByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchJobDetailByIdProvider._internal(
        (ref) => create(ref as FetchJobDetailByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<JobDetailResponse> createElement() {
    return _FetchJobDetailByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchJobDetailByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchJobDetailByIdRef on AutoDisposeFutureProviderRef<JobDetailResponse> {
  /// The parameter `id` of this provider.
  String get id;
}

class _FetchJobDetailByIdProviderElement
    extends AutoDisposeFutureProviderElement<JobDetailResponse>
    with FetchJobDetailByIdRef {
  _FetchJobDetailByIdProviderElement(super.provider);

  @override
  String get id => (origin as FetchJobDetailByIdProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
