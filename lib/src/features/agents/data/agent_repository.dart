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

  /// Get all available agent data
  Future<AvailableAgentsResponse> fetchAvailableAgents({
    required String? categoryId,
  }) async {
    if (categoryId == null || categoryId.trim().isEmpty) {
      final response = await dio.get(kEndPointAvailableAgents);

      final data = AvailableAgentsResponse.fromJson(response.data);
      return data;
    }

    try {
      final response = await dio.get(
        kEndPointAvailableAgents,
        data: {"category_id": categoryId},
      );

      final data = AvailableAgentsResponse.fromJson(response.data);
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
  FetchAvailableAgentsRef ref, {
  required String categoryId,
}) async {
  final provider = ref.watch(agentRepositoryProvider);
  return provider.fetchAvailableAgents(categoryId: categoryId);
}
