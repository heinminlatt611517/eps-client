import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/secure_storage.dart';
import 'api_constants.dart';

part 'dio_provider.g.dart';

@riverpod
Dio dio(DioRef ref) {
  final token = GetStorage().read(SecureDataList.token.name) as String?;

  final client = Dio(
    BaseOptions(
      baseUrl: kBaseUrl, // e.g. https://api.yourdomain.com or https://yourdomain.com/api
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
        // DO NOT set Content-Type globally. Let Dio choose:
        // - application/json for Map
        // - multipart/form-data for FormData
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      // Let us see 3xx/4xx in responses
      validateStatus: (code) => code != null && code >= 100 && code < 600,
      receiveDataWhenStatusError: true,
    ),
  );

  // Optional: quick logging & redirect visibility
  client.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
    ),
  );

  return client;
}

