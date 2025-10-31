import 'package:eps_client/src/features/service_request/mode/service_request_payload.dart';

class ServiceRequestForm {
  final int? serviceId;
  final String? serviceName;
  final String? agentName;

  /// Personal details (manual / scanned)
  final String? number;
  final String? firstName;
  final String? lastName;
  final DateTime? dob;
  final String? nationality;
  final String? gender;
  final DateTime? expiryDate;

  /// Step 3 (docs)
  final List<ServiceDoc> documents;

  /// Step 4 (review)
  final String? note;
  final bool agree;

  const ServiceRequestForm({
    this.serviceId,
    this.serviceName,
    this.agentName,
    this.number,
    this.firstName,
    this.lastName,
    this.dob,
    this.nationality,
    this.gender,
    this.expiryDate,
    this.documents = const [],
    this.note,
    this.agree = false,
  });

  ServiceRequestForm copyWith({
    int? serviceId,
    String? serviceName,
    String? agentName,
    String? number,
    String? firstName,
    String? lastName,
    DateTime? dob,
    String? nationality,
    String? gender,
    DateTime? expiryDate,
    List<ServiceDoc>? documents,
    String? note,
    bool? agree,
  }) {
    return ServiceRequestForm(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      agentName: agentName ?? this.agentName,
      number: number ?? this.number,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dob: dob ?? this.dob,
      nationality: nationality ?? this.nationality,
      gender: gender ?? this.gender,
      expiryDate: expiryDate ?? this.expiryDate,
      documents: documents ?? this.documents,
      note: note ?? this.note,
      agree: agree ?? this.agree,
    );
  }

  /// ---------- gating helpers ----------
  bool get _hasNumber      => (number?.trim().isNotEmpty ?? false);
  bool get _hasFirstName   => (firstName?.trim().isNotEmpty ?? false);
  bool get _hasLastName    => (lastName?.trim().isNotEmpty ?? false);
  bool get _hasDob         => dob != null;
  bool get _hasNationality => (nationality?.trim().isNotEmpty ?? false);
  bool get _hasGender      => (gender?.trim().isNotEmpty ?? false);
  bool get _hasExpiry      => expiryDate != null;

  /// All personal fields must be present (based on your controllers):
  /// number, firstName, lastName, dob, nationality, gender, expiryDate.
  bool get personalComplete =>
      _hasNumber &&
          _hasFirstName &&
          _hasLastName &&
          _hasDob &&
          _hasNationality &&
          _hasGender &&
          _hasExpiry;

  /// step gating
  bool get canProceedFromChoose           => serviceId != null;
  bool get canProceedFromUploadDocs       => personalComplete;
  bool get canProceedFromUploadSupporting => documents.isNotEmpty;
  bool get canSubmit                      => agree;

  /// ---------- payload ----------
  String get _fullName =>
      '${(firstName ?? '').trim()} ${(lastName ?? '').trim()}'.trim();

  ServiceRequestPayload toPayload() {
    final missing = <String>[];
    if (serviceId == null) missing.add('service');
    if (!_hasNumber) missing.add('passport number');
    if (!_hasFirstName) missing.add('first name');
    if (!_hasLastName) missing.add('last name');
    if (!_hasDob) missing.add('date of birth');
    if (!_hasNationality) missing.add('nationality');
    if (!_hasGender) missing.add('gender');
    if (!_hasExpiry) missing.add('expiry date');
    if (missing.isNotEmpty) {
      throw ArgumentError('Please complete: ${missing.join(', ')}.');
    }

    return ServiceRequestPayload(
      serviceId: serviceId!,
      name: _fullName,
      dob: dob!,
      nationality: nationality!.trim(),
      gender: gender!.trim(),
      number: number!.trim(),
      expiryDate: expiryDate!,
      note: (note?.trim().isEmpty ?? true) ? null : note!.trim(),
      documents: documents,
    );
  }
}
