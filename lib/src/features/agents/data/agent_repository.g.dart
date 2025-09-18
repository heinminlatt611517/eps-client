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
    r'0cd165f1f5f2888f13b07e69c776ff9b9dba515f';

/// See also [fetchAvailableAgents].
@ProviderFor(fetchAvailableAgents)
final fetchAvailableAgentsProvider =
    AutoDisposeFutureProvider<AvailableAgentsResponse>.internal(
      fetchAvailableAgents,
      name: r'fetchAvailableAgentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fetchAvailableAgentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FetchAvailableAgentsRef =
    AutoDisposeFutureProviderRef<AvailableAgentsResponse>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
