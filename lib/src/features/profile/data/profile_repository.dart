import 'package:dio/dio.dart';
import 'package:eps_client/src/features/profile/model/profile_data_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../network/api_constants.dart';
import '../../../network/dio_provider.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  ProfileRepository({required this.dio});

  final Dio dio;


  ///get profile data
  Future<ProfileDataResponse> fetchProfileData() async {
    try {
      final response = await dio
          .get(kEndPointProfile);
      ProfileDataResponse data = ProfileDataResponse.fromJson(response.data);
      return data;
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "ERROR: Unknown Dio Error";
    }
  }

  ///edit profile
  Future<void> editProfile(dynamic result) async {
    final formData = FormData.fromMap(result);

    final res = await dio.post(
      kEndPointEditProfile,
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
        followRedirects: false,
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: 'Upload failed with status ${res.statusCode}',
      );
    }
  }

}

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository(dio: ref.watch(dioProvider));
}

@riverpod
Future<ProfileDataResponse> fetchProfileData(
    FetchProfileDataRef ref) async {
  final provider = ref.watch(profileRepositoryProvider);
  return provider.fetchProfileData();
}
