// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_status_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serviceStatusRepositoryHash() =>
    r'27d279300c748860729963229bf331e3a0354128';

/// See also [serviceStatusRepository].
@ProviderFor(serviceStatusRepository)
final serviceStatusRepositoryProvider =
    AutoDisposeProvider<ServiceStatusRepository>.internal(
      serviceStatusRepository,
      name: r'serviceStatusRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$serviceStatusRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ServiceStatusRepositoryRef =
    AutoDisposeProviderRef<ServiceStatusRepository>;
String _$fetchAllCustomerServiceStatusHash() =>
    r'457379dff62eafce35014d59760b690851ded536';

/// See also [fetchAllCustomerServiceStatus].
@ProviderFor(fetchAllCustomerServiceStatus)
final fetchAllCustomerServiceStatusProvider =
    AutoDisposeFutureProvider<ServiceStatusResponse>.internal(
      fetchAllCustomerServiceStatus,
      name: r'fetchAllCustomerServiceStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fetchAllCustomerServiceStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FetchAllCustomerServiceStatusRef =
    AutoDisposeFutureProviderRef<ServiceStatusResponse>;
String _$fetchServiceStatusDetailsByIdHash() =>
    r'ab6b2ecaaac9dcb79fb18921e2432c1ab8b1755c';

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

/// See also [fetchServiceStatusDetailsById].
@ProviderFor(fetchServiceStatusDetailsById)
const fetchServiceStatusDetailsByIdProvider =
    FetchServiceStatusDetailsByIdFamily();

/// See also [fetchServiceStatusDetailsById].
class FetchServiceStatusDetailsByIdFamily
    extends Family<AsyncValue<ServiceStatusDetailsResponse>> {
  /// See also [fetchServiceStatusDetailsById].
  const FetchServiceStatusDetailsByIdFamily();

  /// See also [fetchServiceStatusDetailsById].
  FetchServiceStatusDetailsByIdProvider call({required String id}) {
    return FetchServiceStatusDetailsByIdProvider(id: id);
  }

  @override
  FetchServiceStatusDetailsByIdProvider getProviderOverride(
    covariant FetchServiceStatusDetailsByIdProvider provider,
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
  String? get name => r'fetchServiceStatusDetailsByIdProvider';
}

/// See also [fetchServiceStatusDetailsById].
class FetchServiceStatusDetailsByIdProvider
    extends AutoDisposeFutureProvider<ServiceStatusDetailsResponse> {
  /// See also [fetchServiceStatusDetailsById].
  FetchServiceStatusDetailsByIdProvider({required String id})
    : this._internal(
        (ref) => fetchServiceStatusDetailsById(
          ref as FetchServiceStatusDetailsByIdRef,
          id: id,
        ),
        from: fetchServiceStatusDetailsByIdProvider,
        name: r'fetchServiceStatusDetailsByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fetchServiceStatusDetailsByIdHash,
        dependencies: FetchServiceStatusDetailsByIdFamily._dependencies,
        allTransitiveDependencies:
            FetchServiceStatusDetailsByIdFamily._allTransitiveDependencies,
        id: id,
      );

  FetchServiceStatusDetailsByIdProvider._internal(
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
    FutureOr<ServiceStatusDetailsResponse> Function(
      FetchServiceStatusDetailsByIdRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchServiceStatusDetailsByIdProvider._internal(
        (ref) => create(ref as FetchServiceStatusDetailsByIdRef),
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
  AutoDisposeFutureProviderElement<ServiceStatusDetailsResponse>
  createElement() {
    return _FetchServiceStatusDetailsByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchServiceStatusDetailsByIdProvider && other.id == id;
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
mixin FetchServiceStatusDetailsByIdRef
    on AutoDisposeFutureProviderRef<ServiceStatusDetailsResponse> {
  /// The parameter `id` of this provider.
  String get id;
}

class _FetchServiceStatusDetailsByIdProviderElement
    extends AutoDisposeFutureProviderElement<ServiceStatusDetailsResponse>
    with FetchServiceStatusDetailsByIdRef {
  _FetchServiceStatusDetailsByIdProviderElement(super.provider);

  @override
  String get id => (origin as FetchServiceStatusDetailsByIdProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
