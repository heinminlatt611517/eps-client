class PassportMrz {
  final String? issuingCountry;
  final String? documentNumber;
  final String? nationality;
  final DateTime? birthDate;
  final String? sex;
  final DateTime? expiryDate;
  final String? primaryIdentifier;
  final String? secondaryIdentifier;

  PassportMrz({
     this.issuingCountry,
     this.documentNumber,
     this.nationality,
     this.birthDate,
     this.sex,
     this.expiryDate,
     this.primaryIdentifier,
     this.secondaryIdentifier,
  });

  @override
  String toString() =>
      'PassportMrz(doc=$documentNumber, $primaryIdentifier $secondaryIdentifier, $nationality, '
          'dob=$birthDate, sex=$sex, exp=$expiryDate, iss=$issuingCountry)';
}