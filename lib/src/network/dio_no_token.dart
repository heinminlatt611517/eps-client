import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'api_constants.dart';

part 'dio_no_token.g.dart';

@riverpod
Dio dioNoToken(DioNoTokenRef ref) {
  return Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 10000),
      responseType: ResponseType.json,
    ),
  );
}