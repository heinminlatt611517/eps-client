import 'package:dio/dio.dart';
import 'package:eps_client/src/network/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../network/dio_provider.dart';
import '../../../network/error_handler.dart';
import '../model/availabel_agent_response.dart';

part 'agent_repository.g.dart';

class AgentRepository {
  AgentRepository({required this.ref, required this.dio});

  final Ref ref;
  final Dio dio;

  ///get all available agent data
  Future<AvailableAgentsResponse> fetchAvailableAgents() async {
    try {
      final response = await dio.get(kEndPointAvailableAgents);
      AvailableAgentsResponse data = AvailableAgentsResponse.fromJson(
        response.data,
      );

      return data;
    } on DioException catch (e) {
      throw e.response?.data["message"] ??
          ErrorHandler.handle(e).failure.message;
    }
  }
}

@riverpod
AgentRepository agentRepository(AgentRepositoryRef ref) {
  return AgentRepository(dio: ref.watch(dioProvider), ref: ref);
}

@riverpod
Future<AvailableAgentsResponse> fetchAvailableAgents(
  FetchAvailableAgentsRef ref,
) async {
  final provider = ref.watch(agentRepositoryProvider);
  return provider.fetchAvailableAgents();
}
