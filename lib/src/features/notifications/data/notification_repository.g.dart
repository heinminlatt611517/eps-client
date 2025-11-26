// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationRepositoryHash() =>
    r'9443167c3ecc6a7e90c6646df05b3ac55a37dd98';

/// See also [notificationRepository].
@ProviderFor(notificationRepository)
final notificationRepositoryProvider =
    AutoDisposeProvider<NotificationRepository>.internal(
      notificationRepository,
      name: r'notificationRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationRepositoryRef =
    AutoDisposeProviderRef<NotificationRepository>;
String _$fetchAllNotificationsHash() =>
    r'bd542e71a32ae50efa9c59cb13ef4b374ce4303b';

/// See also [fetchAllNotifications].
@ProviderFor(fetchAllNotifications)
final fetchAllNotificationsProvider =
    AutoDisposeFutureProvider<NotificationResponse>.internal(
      fetchAllNotifications,
      name: r'fetchAllNotificationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fetchAllNotificationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FetchAllNotificationsRef =
    AutoDisposeFutureProviderRef<NotificationResponse>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
