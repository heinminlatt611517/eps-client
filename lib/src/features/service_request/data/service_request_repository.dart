import 'package:dio/dio.dart';
import 'package:eps_client/src/network/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../network/dio_provider.dart';
import '../../../network/error_handler.dart';
import '../mode/service_request_payload.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'service_request_repository.g.dart';

class ServiceRequestRepository {
  final Dio dio;
  final Ref ref;
  ServiceRequestRepository({required this.ref, required this.dio});

  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  Future<void> submitServiceRequest(ServiceRequestPayload p) async {
    try {
      final form = FormData.fromMap({
        'service_id': p.serviceId.toString(),
        'name': p.name,
        'dob': _ymd(p.dob),
        'nationality': p.nationality,
        'gender': p.gender,
        'number': p.number,
        'expiry_date': _ymd(p.expiryDate),
        if ((p.note ?? '').trim().isNotEmpty) 'note': p.note!.trim(),
      });

      for (var i = 0; i < p.documents.length; i++) {
        final d = p.documents[i];
        form.fields.add(MapEntry('documents[$i][type]', d.type));
        form.files.add(
          MapEntry(
            'documents[$i][file]',
            await MultipartFile.fromFile(
              d.file.path,
              filename: d.file.uri.pathSegments.last,
            ),
          ),
        );
      }

      final res = await dio.post(
        kEndPointPostRequestService,
        data: form,
        options: Options(
          followRedirects: false,
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (res.statusCode != null && res.statusCode! >= 300 && res.statusCode! < 400) {
        throw 'Server redirected (status ${res.statusCode}). Check base URL / endpoint.';
      }
    } on DioException catch (e) {
      debugPrint("DioError>>>>${e.response?.data}");
      throw e.response?.data?["message"] ??
          ErrorHandler.handle(e).failure.message;
    }
  }

}

@riverpod
ServiceRequestRepository serviceRequestRepository(ServiceRequestRepositoryRef ref) {
  return ServiceRequestRepository(dio: ref.watch(dioProvider), ref: ref);
}