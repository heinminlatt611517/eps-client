import 'package:dio/dio.dart';
import 'package:eps_client/src/features/job_opportunities/model/jobs_response.dart';
import 'package:eps_client/src/features/notifications/model/notification_response.dart';
import 'package:eps_client/src/network/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../network/dio_provider.dart';
import '../../../network/error_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_repository.g.dart';

class NotificationRepository {
  final Dio dio;
  final Ref ref;
  NotificationRepository({required this.ref, required this.dio});

  ///get all available agent data
  Future<NotificationResponse> fetchAllNotifications() async {
    try {
      final response = await dio.get(kEndPointNotifications);
      NotificationResponse data = NotificationResponse.fromJson(
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
NotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  return NotificationRepository(dio: ref.watch(dioProvider), ref: ref);
}

@riverpod
Future<NotificationResponse> fetchAllNotifications(
    FetchAllNotificationsRef ref,
    ) async {
  final provider = ref.watch(notificationRepositoryProvider);
  return provider.fetchAllNotifications();
}
