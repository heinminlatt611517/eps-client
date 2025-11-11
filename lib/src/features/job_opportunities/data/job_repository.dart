import 'package:dio/dio.dart';
import 'package:eps_client/src/features/job_opportunities/model/job_detail_response.dart';
import 'package:eps_client/src/features/job_opportunities/model/jobs_response.dart';
import 'package:eps_client/src/network/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../network/dio_provider.dart';
import '../../../network/error_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'job_repository.g.dart';

class JobRepository {
  final Dio dio;
  final Ref ref;
  JobRepository({required this.ref, required this.dio});

  ///get all available agent data
  Future<JobsResponse> fetchAllJobs() async {
    try {
      final response = await dio.get(kEndPointGetJobs);
      JobsResponse data = JobsResponse.fromJson(
        response.data,
      );

      return data;
    } on DioException catch (e) {
      throw e.response?.data["message"] ??
          ErrorHandler.handle(e).failure.message;
    }
  }

  ///get job details by id
  Future<JobDetailResponse> getJobDetailById({required String id}) async {
    try {
      final response = await dio.get(kEndPointJobDetails, data: {"id": id});
      JobDetailResponse data = JobDetailResponse.fromJson(response.data);

      return data;
    } on DioException catch (e) {
      throw e.response?.data["message"] ??
          ErrorHandler.handle(e).failure.message;
    }
  }

}

@riverpod
JobRepository jobRepository(JobRepositoryRef ref) {
  return JobRepository(dio: ref.watch(dioProvider), ref: ref);
}

@riverpod
Future<JobsResponse> fetchAllJobs(
    FetchAllJobsRef ref,
    ) async {
  final provider = ref.watch(jobRepositoryProvider);
  return provider.fetchAllJobs();
}

@riverpod
Future<JobDetailResponse> fetchJobDetailById(
    FetchJobDetailByIdRef ref, {
      required String id,
    }) async {
  final provider = ref.watch(jobRepositoryProvider);
  return provider.getJobDetailById(id: id);
}
