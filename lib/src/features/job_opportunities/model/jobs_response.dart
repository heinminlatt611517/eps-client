// To parse this JSON data, do
//
//     final jobsResponse = jobsResponseFromJson(jsonString);

import 'dart:convert';

JobsResponse jobsResponseFromJson(String str) => JobsResponse.fromJson(json.decode(str));

String jobsResponseToJson(JobsResponse data) => json.encode(data.toJson());

class JobsResponse {
  int? status;
  String? message;
  List<JobVO>? data;

  JobsResponse({
    this.status,
    this.message,
    this.data,
  });

  factory JobsResponse.fromJson(Map<String, dynamic> json) => JobsResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<JobVO>.from(json["data"]!.map((x) => JobVO.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class JobVO {
  int? id;
  String? title;
  String? location;
  String? type;
  String? salary;
  DateTime? updatedAt;
  DateTime? createdAt;

  JobVO({
    this.id,
    this.title,
    this.location,
    this.type,
    this.salary,
    this.updatedAt,
    this.createdAt,
  });

  factory JobVO.fromJson(Map<String, dynamic> json) => JobVO(
    id: json["id"],
    title: json["title"],
    location: json["location"],
    type: json["type"],
    salary: json["salary"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "location": location,
    "type" : type,
    "salary": salary,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
  };
}
