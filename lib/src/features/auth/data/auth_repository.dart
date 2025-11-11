import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../exceptions/app_exception.dart';
import '../../../network/api_constants.dart';
import '../../../network/dio_no_token.dart';
import '../../../network/error_handler.dart';
import '../../../utils/secure_storage.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  AuthRepository({required this.dio, required this.ref});

  final Dio dio;
  final Ref ref;

  ///login
  Future<void> login({required email, required password}) async {
    if (password.length < 1) {
      throw EmptyPhoneNumberOrPasswordException();
    }
    try {
      final baseOptions = BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: {"Content-Type": "application/json"},
      );

      final dio = Dio(baseOptions);
      final response = await dio.post(
        kEndPointLogin,
        options: Options(headers: {"Content-Type": "application/json"}),
        data: {"email": email, "password": password},
      );
      final tokenBox = GetStorage();

      tokenBox.write(SecureDataList.token.name, response.data['token']);
      SecureStorage().saveUserName(response.data['data']['name']);
    } on DioException catch (e) {
      throw e.response?.data["message"] ??
          ErrorHandler.handle(e).failure.message;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signUp(dynamic payload) async {
    try {
      final baseOptions = BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: {"Content-Type": "application/json"},
      );

      final dio = Dio(baseOptions);
      final response = await dio.post(
        kEndPointRegister,
        options: Options(headers: {"Content-Type": "application/json"}),
        data: payload,
      );

      final tokenBox = GetStorage();
      tokenBox.write(SecureDataList.token.name, response.data['token']);
      tokenBox.write(
        SecureDataList.userName.name,
        response.data['data']['name'],
      );
    } on DioException catch (e) {
      throw e.response?.data["message"] ??
          ErrorHandler.handle(e).failure.message;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signInWithGoogle() async {}
}

@riverpod
AuthRepository authRepositoryNoToken(AuthRepositoryNoTokenRef ref) {
  return AuthRepository(dio: ref.watch(dioNoTokenProvider), ref: ref);
}
