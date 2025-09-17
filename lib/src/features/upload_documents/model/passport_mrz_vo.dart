class PassportMrz {
  final String issuingCountry;
  final String documentNumber;
  final String nationality;
  final DateTime? birthDate;
  final String sex;
  final DateTime? expiryDate;
  final String primaryIdentifier;
  final String secondaryIdentifier;

  PassportMrz({
    required this.issuingCountry,
    required this.documentNumber,
    required this.nationality,
    required this.birthDate,
    required this.sex,
    required this.expiryDate,
    required this.primaryIdentifier,
    required this.secondaryIdentifier,
  });

  @override
  String toString() =>
      'PassportMrz(doc=$documentNumber, $primaryIdentifier $secondaryIdentifier, $nationality, '
          'dob=$birthDate, sex=$sex, exp=$expiryDate, iss=$issuingCountry)';
}