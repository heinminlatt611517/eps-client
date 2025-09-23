class IdFields {
  String? idNumber;       // e.g. CC8094288, 0063062890665, etc.
  String? eoiNo;          // if present separately
  String? name;           // KO THU / Mr. Myint Thein
  String? nationality;    // MYANMAR / THAI etc.
  String? gender;         // M / F
  String? dateOfBirth;    // ISO yyyy-MM-dd
  String? dateOfIssue;    // ISO
  String? dateOfExpiry;   // ISO
  String? placeOfBirth;   // Kyaikto
  String? authority;      // OESC, CHIANG MAI
  String rawText;         // for debugging

  IdFields({required this.rawText});
}