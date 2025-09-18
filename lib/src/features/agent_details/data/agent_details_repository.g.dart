// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_details_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$agentDetailsRepositoryHash() =>
    r'a7a4186b0277fae8f89f9afe67389e3f165a7f81';

/// See also [agentDetailsRepository].
@ProviderFor(agentDetailsRepository)
final agentDetailsRepositoryProvider =
    AutoDisposeProvider<AgentDetailsRepository>.internal(
      agentDetailsRepository,
      name: r'agentDetailsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$agentDetailsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AgentDetailsRepositoryRef =
    AutoDisposeProviderRef<AgentDetailsRepository>;
String _$fetchAgentDetailsByIdHash() =>
    r'465f2989590c9d50b2e5ed48b6354fe5ac3420c6';

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

/// See also [fetchAgentDetailsById].
@ProviderFor(fetchAgentDetailsById)
const fetchAgentDetailsByIdProvider = FetchAgentDetailsByIdFamily();

/// See also [fetchAgentDetailsById].
class FetchAgentDetailsByIdFamily
    extends Family<AsyncValue<AgentDetailsResponse>> {
  /// See also [fetchAgentDetailsById].
  const FetchAgentDetailsByIdFamily();

  /// See also [fetchAgentDetailsById].
  FetchAgentDetailsByIdProvider call({required String id}) {
    return FetchAgentDetailsByIdProvider(id: id);
  }

  @override
  FetchAgentDetailsByIdProvider getProviderOverride(
    covariant FetchAgentDetailsByIdProvider provider,
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
  String? get name => r'fetchAgentDetailsByIdProvider';
}

/// See also [fetchAgentDetailsById].
class FetchAgentDetailsByIdProvider
    extends AutoDisposeFutureProvider<AgentDetailsResponse> {
  /// See also [fetchAgentDetailsById].
  FetchAgentDetailsByIdProvider({required String id})
    : this._internal(
        (ref) => fetchAgentDetailsById(ref as FetchAgentDetailsByIdRef, id: id),
        from: fetchAgentDetailsByIdProvider,
        name: r'fetchAgentDetailsByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fetchAgentDetailsByIdHash,
        dependencies: FetchAgentDetailsByIdFamily._dependencies,
        allTransitiveDependencies:
            FetchAgentDetailsByIdFamily._allTransitiveDependencies,
        id: id,
      );

  FetchAgentDetailsByIdProvider._internal(
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
    FutureOr<AgentDetailsResponse> Function(FetchAgentDetailsByIdRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchAgentDetailsByIdProvider._internal(
        (ref) => create(ref as FetchAgentDetailsByIdRef),
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
  AutoDisposeFutureProviderElement<AgentDetailsResponse> createElement() {
    return _FetchAgentDetailsByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchAgentDetailsByIdProvider && other.id == id;
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
mixin FetchAgentDetailsByIdRef
    on AutoDisposeFutureProviderRef<AgentDetailsResponse> {
  /// The parameter `id` of this provider.
  String get id;
}

class _FetchAgentDetailsByIdProviderElement
    extends AutoDisposeFutureProviderElement<AgentDetailsResponse>
    with FetchAgentDetailsByIdRef {
  _FetchAgentDetailsByIdProviderElement(super.provider);

  @override
  String get id => (origin as FetchAgentDetailsByIdProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
