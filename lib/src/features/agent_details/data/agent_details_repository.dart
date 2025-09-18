import 'package:dio/dio.dart';
import 'package:eps_client/src/features/agent_details/model/agent_details_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../network/api_constants.dart';
import '../../../network/dio_provider.dart';
import '../../../network/error_handler.dart';

part 'agent_details_repository.g.dart';

class AgentDetailsRepository {
  AgentDetailsRepository({required this.ref, required this.dio});

  final Ref ref;
  final Dio dio;

  ///get agent details by id
  Future<AgentDetailsResponse> getAgentDetailsById({required String id}) async {
    try {
      final response = await dio.get(kEndPointAgentDetails, data: {"id": id});
      AgentDetailsResponse data = AgentDetailsResponse.fromJson(response.data);

      return data;
    } on DioException catch (e) {
      throw e.response?.data["message"] ??
          ErrorHandler.handle(e).failure.message;
    }
  }
}

@riverpod
AgentDetailsRepository agentDetailsRepository(AgentDetailsRepositoryRef ref) {
  return AgentDetailsRepository(dio: ref.watch(dioProvider), ref: ref);
}

@riverpod
Future<AgentDetailsResponse> fetchAgentDetailsById(
  FetchAgentDetailsByIdRef ref, {
  required String id,
}) async {
  final provider = ref.watch(agentDetailsRepositoryProvider);
  return provider.getAgentDetailsById(id: id);
}
