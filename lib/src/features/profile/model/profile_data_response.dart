import 'dart:convert';

ProfileDataResponse profileDataResponseFromJson(String str) => ProfileDataResponse.fromJson(json.decode(str));

String profileDataResponseToJson(ProfileDataResponse data) => json.encode(data.toJson());

class ProfileDataResponse {
  int? status;
  String? message;
  UserVO? data;

  ProfileDataResponse({
    this.status,
    this.message,
    this.data,
  });

  factory ProfileDataResponse.fromJson(Map<String, dynamic> json) => ProfileDataResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : UserVO.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class UserVO {
  int? id;
  String? customerId;
  String? cusId;
  String? name;
  dynamic nameMm;
  String? sex;
  DateTime? dob;
  dynamic nrcNo;
  dynamic prevPassportNo;
  dynamic passportNo;
  dynamic passportExpiry;
  dynamic visaType;
  dynamic visaNumber;
  dynamic visaExpiry;
  dynamic ciNo;
  dynamic ciExpiry;
  dynamic pinkCardNo;
  dynamic pinkCardExpiry;
  String? email;
  String? phone;
  dynamic phoneSecondary;
  String? address;

  UserVO({
    this.id,
    this.customerId,
    this.cusId,
    this.name,
    this.nameMm,
    this.sex,
    this.dob,
    this.nrcNo,
    this.prevPassportNo,
    this.passportNo,
    this.passportExpiry,
    this.visaType,
    this.visaNumber,
    this.visaExpiry,
    this.ciNo,
    this.ciExpiry,
    this.pinkCardNo,
    this.pinkCardExpiry,
    this.email,
    this.phone,
    this.phoneSecondary,
    this.address,
  });

  factory UserVO.fromJson(Map<String, dynamic> json) => UserVO(
    id: json["id"],
    customerId: json["customer_id"],
    cusId: json["cus_id"],
    name: json["name"],
    nameMm: json["name_mm"],
    sex: json["sex"],
    dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
    nrcNo: json["nrc_no"],
    prevPassportNo: json["prev_passport_no"],
    passportNo: json["passport_no"],
    passportExpiry: json["passport_expiry"],
    visaType: json["visa_type"],
    visaNumber: json["visa_number"],
    visaExpiry: json["visa_expiry"],
    ciNo: json["ci_no"],
    ciExpiry: json["ci_expiry"],
    pinkCardNo: json["pink_card_no"],
    pinkCardExpiry: json["pink_card_expiry"],
    email: json["email"],
    phone: json["phone"],
    phoneSecondary: json["phone_secondary"],
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "customer_id": customerId,
    "cus_id": cusId,
    "name": name,
    "name_mm": nameMm,
    "sex": sex,
    "dob": "${dob!.year.toString().padLeft(4, '0')}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}",
    "nrc_no": nrcNo,
    "prev_passport_no": prevPassportNo,
    "passport_no": passportNo,
    "passport_expiry": passportExpiry,
    "visa_type": visaType,
    "visa_number": visaNumber,
    "visa_expiry": visaExpiry,
    "ci_no": ciNo,
    "ci_expiry": ciExpiry,
    "pink_card_no": pinkCardNo,
    "pink_card_expiry": pinkCardExpiry,
    "email": email,
    "phone": phone,
    "phone_secondary": phoneSecondary,
    "address": address,
  };
}
