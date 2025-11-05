import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../mode/service_request_payload.dart';
import 'service_request_form.dart';

part 'service_request_form_notifier.g.dart';

@riverpod
class ServiceRequestFormNotifier extends _$ServiceRequestFormNotifier {
  @override
  ServiceRequestForm build() => const ServiceRequestForm();

  /// step 1
  void setService({required int id}) =>
      state = state.copyWith(serviceId: id);
  void setAgent(String name) =>
      state = state.copyWith(agentName: name);

  /// step 2
  void setPersonal({
    String? number,
    String? firstName,
    String? lastName,
    DateTime? dob,
    String? nationality,
    String? gender,
    DateTime? expiryDate,
  }) {
    state = state.copyWith(
      number: number ?? state.number,
      firstName: firstName ?? state.firstName,
      lastName: lastName ?? state.lastName,
      dob: dob ?? state.dob,
      nationality: nationality ?? state.nationality,
      gender: gender ?? state.gender,
      expiryDate: expiryDate ?? state.expiryDate,
    );
  }

  /// step 3
  void upsertDocument({required String type, required File file}) {
    final list = [...state.documents];
    final i = list.indexWhere((d) => d.type == type);
    final doc = ServiceDoc(type: type, file: file);
    if (i == -1) {
      list.add(doc);
    } else {
      list[i] = doc;
    }
    state = state.copyWith(documents: list);
  }

  void removeDocument(String type) =>
      state = state.copyWith(
        documents: state.documents.where((d) => d.type != type).toList(),
      );

  /// step 4
  void setNote(String? v) => state = state.copyWith(note: v);
  void setDocumentType(String? v) => state = state.copyWith(documentType: v);
  void setAgree(bool v)   => state = state.copyWith(agree: v);
  void setAgreeTerm(bool v)   => state = state.copyWith(agreeTerm: v);

  void reset() => state = const ServiceRequestForm();
}
