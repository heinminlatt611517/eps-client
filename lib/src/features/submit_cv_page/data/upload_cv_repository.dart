import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eps_client/src/network/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../network/dio_provider.dart';
import '../../../network/error_handler.dart';
import 'package:mime/mime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as p;
import 'package:http_parser/http_parser.dart';

part 'upload_cv_repository.g.dart';

class UploadCVRepository {
  final Dio dio;
  final Ref ref;

  UploadCVRepository({required this.ref, required this.dio});

  Future<void> submitCv(File file) async {
    final fileName = p.basename(file.path);
    final mime = lookupMimeType(file.path) ?? 'application/octet-stream';
    final mediaType = MediaType.parse(mime);

    final form = FormData.fromMap({
      'cv': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: mediaType,
      ),
    });

    final res = await dio.post(
      kEndPointUploadCV,
      data: form,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
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
UploadCVRepository uploadCVRepository(UploadCVRepositoryRef ref) {
  return UploadCVRepository(dio: ref.watch(dioProvider), ref: ref);
}
