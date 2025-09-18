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
  final headers = <String, String>{
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  final client = Dio(BaseOptions(
    baseUrl: kBaseUrl,
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 20),
    responseType: ResponseType.json,
    headers: headers,
    validateStatus: (code) => code != null && code >= 100 && code < 600,
    receiveDataWhenStatusError: true,
  ));

  return client;
}
