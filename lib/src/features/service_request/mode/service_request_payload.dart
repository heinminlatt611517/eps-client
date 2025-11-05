import 'dart:io';

class ServiceDoc {
  final String type;
  final File file;
  const ServiceDoc({required this.type, required this.file});
}

class ServiceRequestPayload {
  final int serviceId;
  final String name;
  final DateTime dob;
  final String nationality;
  final String gender;
  final String number;
  final DateTime expiryDate;
  final String? note;
  final List<ServiceDoc> documents;
  final String? documentType;

  const ServiceRequestPayload({
    required this.serviceId,
    required this.name,
    required this.dob,
    required this.nationality,
    required this.gender,
    required this.number,
    required this.expiryDate,
    this.note,
    required this.documents,
    required this.documentType
  });
}
