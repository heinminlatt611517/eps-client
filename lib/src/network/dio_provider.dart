import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/secure_storage.dart';
import 'api_constants.dart';

part 'dio_provider.g.dart';

@riverpod
Dio dio(DioRef ref) {
  final token = GetStorage().read(SecureDataList.token.name);
  debugPrint("BearerToken$token");
  String tokenWithBearer = "Bearer ${token!}";
  return Dio(
    BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        responseType: ResponseType.json,
        headers: {
          "Content-Type": "application/json",
          "Authorization": tokenWithBearer
        }),
  );
}