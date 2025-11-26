// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$agentRepositoryHash() => r'10ff99556229eb67b459ce3ad68b06cfd4afdb8c';

/// See also [agentRepository].
@ProviderFor(agentRepository)
final agentRepositoryProvider = AutoDisposeProvider<AgentRepository>.internal(
  agentRepository,
  name: r'agentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$agentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AgentRepositoryRef = AutoDisposeProviderRef<AgentRepository>;
String _$fetchAvailableAgentsHash() =>
    r'9022896424e6442e314cf4b9e74efbb02e8669ab';

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

/// See also [fetchAvailableAgents].
@ProviderFor(fetchAvailableAgents)
const fetchAvailableAgentsProvider = FetchAvailableAgentsFamily();

/// See also [fetchAvailableAgents].
class FetchAvailableAgentsFamily
    extends Family<AsyncValue<AvailableAgentsResponse>> {
  /// See also [fetchAvailableAgents].
  const FetchAvailableAgentsFamily();

  /// See also [fetchAvailableAgents].
  FetchAvailableAgentsProvider call({required String categoryId}) {
    return FetchAvailableAgentsProvider(categoryId: categoryId);
  }

  @override
  FetchAvailableAgentsProvider getProviderOverride(
    covariant FetchAvailableAgentsProvider provider,
  ) {
    return call(categoryId: provider.categoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fetchAvailableAgentsProvider';
}

/// See also [fetchAvailableAgents].
class FetchAvailableAgentsProvider
    extends AutoDisposeFutureProvider<AvailableAgentsResponse> {
  /// See also [fetchAvailableAgents].
  FetchAvailableAgentsProvider({required String categoryId})
    : this._internal(
        (ref) => fetchAvailableAgents(
          ref as FetchAvailableAgentsRef,
          categoryId: categoryId,
        ),
        from: fetchAvailableAgentsProvider,
        name: r'fetchAvailableAgentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fetchAvailableAgentsHash,
        dependencies: FetchAvailableAgentsFamily._dependencies,
        allTransitiveDependencies:
            FetchAvailableAgentsFamily._allTransitiveDependencies,
        categoryId: categoryId,
      );

  FetchAvailableAgentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final String categoryId;

  @override
  Override overrideWith(
    FutureOr<AvailableAgentsResponse> Function(FetchAvailableAgentsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchAvailableAgentsProvider._internal(
        (ref) => create(ref as FetchAvailableAgentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AvailableAgentsResponse> createElement() {
    return _FetchAvailableAgentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchAvailableAgentsProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchAvailableAgentsRef
    on AutoDisposeFutureProviderRef<AvailableAgentsResponse> {
  /// The parameter `categoryId` of this provider.
  String get categoryId;
}

class _FetchAvailableAgentsProviderElement
    extends AutoDisposeFutureProviderElement<AvailableAgentsResponse>
    with FetchAvailableAgentsRef {
  _FetchAvailableAgentsProviderElement(super.provider);

  @override
  String get categoryId => (origin as FetchAvailableAgentsProvider).categoryId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
