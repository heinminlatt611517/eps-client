import 'dart:convert';

import 'package:eps_client/src/features/job_opportunities/model/jobs_response.dart';

JobDetailResponse jobDetailResponseFromJson(String str) =>
    JobDetailResponse.fromJson(json.decode(str));

String jobDetailResponseToJson(JobDetailResponse data) =>
    json.encode(data.toJson());

class JobDetailResponse {
  int? status;
  String? message;
  JobVO? data;

  JobDetailResponse({this.status, this.message, this.data});

  factory JobDetailResponse.fromJson(Map<String, dynamic> json) =>
      JobDetailResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : JobVO.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}
