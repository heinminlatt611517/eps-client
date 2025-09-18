import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../network/dio_provider.dart';

part 'service_status_repository.g.dart';

class ServiceStatusRepository {
  ServiceStatusRepository({required this.ref, required this.dio});

  final Ref ref;
  final Dio dio;
}

@riverpod
ServiceStatusRepository serviceStatusRepository(ServiceStatusRepositoryRef ref) {
  return ServiceStatusRepository(dio: ref.watch(dioProvider), ref: ref);
}
