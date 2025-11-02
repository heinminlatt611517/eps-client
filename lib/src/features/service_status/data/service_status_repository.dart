import 'package:dio/dio.dart';
import 'package:eps_client/src/features/service_status/model/service_status_details_response.dart';
import 'package:eps_client/src/features/service_status/model/service_status_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../network/api_constants.dart';
import '../../../network/dio_provider.dart';
import '../../../network/error_handler.dart';

part 'service_status_repository.g.dart';

class ServiceStatusRepository {
  ServiceStatusRepository({required this.ref, required this.dio});

  final Ref ref;
  final Dio dio;

  ///get all service status data
  Future<ServiceStatusResponse> fetchAllCustomerServiceStatus() async {
    try {
      final response = await dio.get(kEndPointGetAllCustomerServiceStatus);
      ServiceStatusResponse data = ServiceStatusResponse.fromJson(
        response.data,
      );

      return data;
    } on DioException catch (e) {
      throw e.response?.data["message"] ??
          ErrorHandler.handle(e).failure.message;
    }
  }

  ///get customer service status details by id
  Future<ServiceStatusDetailsResponse> getServiceStatusDetailsById({required String id}) async {
    try {
      final response = await dio.get(kEndPointServiceStatusDetails, data: {"id": id});
      ServiceStatusDetailsResponse data = ServiceStatusDetailsResponse.fromJson(response.data);

      return data;
    } on DioException catch (e) {
      throw e.response?.data["message"] ??
          ErrorHandler.handle(e).failure.message;
    }
  }
}

@riverpod
ServiceStatusRepository serviceStatusRepository(ServiceStatusRepositoryRef ref) {
  return ServiceStatusRepository(dio: ref.watch(dioProvider), ref: ref);
}

@riverpod
Future<ServiceStatusResponse> fetchAllCustomerServiceStatus(
    FetchAllCustomerServiceStatusRef ref,
    ) async {
  final provider = ref.watch(serviceStatusRepositoryProvider);
  return provider.fetchAllCustomerServiceStatus();
}

@riverpod
Future<ServiceStatusDetailsResponse> fetchServiceStatusDetailsById(
    FetchServiceStatusDetailsByIdRef ref, {
      required String id,
    }) async {
  final provider = ref.watch(serviceStatusRepositoryProvider);
  return provider.getServiceStatusDetailsById(id: id);
}
