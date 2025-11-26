import 'dart:convert';

CategoryResponse categoryResponseFromJson(String str) => CategoryResponse.fromJson(json.decode(str));

String categoryResponseToJson(CategoryResponse data) => json.encode(data.toJson());

class CategoryResponse {
  int? status;
  String? message;
  List<CategoryVO>? data;

  CategoryResponse({
    this.status,
    this.message,
    this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) => CategoryResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<CategoryVO>.from(json["data"]!.map((x) => CategoryVO.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class CategoryVO {
  int? id;
  Name? name;
  DateTime? updatedAt;
  DateTime? createdAt;

  CategoryVO({
    this.id,
    this.name,
    this.updatedAt,
    this.createdAt,
  });

  factory CategoryVO.fromJson(Map<String, dynamic> json) => CategoryVO(
    id: json["id"],
    name: nameValues.map[json["name"]]!,
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": nameValues.reverse[name],
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
  };
}

enum Name {
  CI,
  DRIVING_LICENCE,
  PASSPORT,
  PINK_CARD,
  VISA
}

final nameValues = EnumValues({
  "CI": Name.CI,
  "Driving Licence": Name.DRIVING_LICENCE,
  "Passport": Name.PASSPORT,
  "Pink Card": Name.PINK_CARD,
  "Visa": Name.VISA
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
