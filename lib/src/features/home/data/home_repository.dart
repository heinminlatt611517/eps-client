import 'package:dio/dio.dart';
import 'package:eps_client/src/features/home/model/category_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../network/api_constants.dart';
import '../../../network/dio_provider.dart';
import '../../../network/error_handler.dart';
import '../../../utils/secure_storage.dart';

part 'home_repository.g.dart';

class HomeRepository {
  HomeRepository({required this.ref, required this.dio});

  final Ref ref;
  final Dio dio;

  ///get all categories
  Future<CategoryResponse> fetchCategories() async {
    try {
      final response = await dio.get(kEndPointCategories);
      CategoryResponse data = CategoryResponse.fromJson(response.data);
      final store = SecureStorage();
      await store.saveCategories(data.data ?? []);

      return data;
    } on DioException catch (e) {
      throw e.response?.data["message"] ??
          ErrorHandler.handle(e).failure.message;
    }
  }

  ///get all categories
  Future<void> saveFcmToken() async {
    final fcmToken = ref.watch(getFcmTokenProvider);
    debugPrint("FcmToken>>>>$fcmToken");
    try {
      final response = await dio.post(
        kEndPointSaveFcmToken,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
        data: {"firebase_token": fcmToken},
      );
      debugPrint("SaveFCMTokenResponse>>>>>>>>>>$response");
    } on DioException catch (e) {
      throw e.response?.data["message"] ??
          ErrorHandler.handle(e).failure.message;
    }
  }
}

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  return HomeRepository(dio: ref.watch(dioProvider), ref: ref);
}

@riverpod
Future<CategoryResponse> fetchCategories(FetchCategoriesRef ref) async {
  final provider = ref.watch(homeRepositoryProvider);
  return provider.fetchCategories();
}
