// To parse this JSON data, do
//
//     final serviceStatusResponse = serviceStatusResponseFromJson(jsonString);

import 'dart:convert';

ServiceStatusResponse serviceStatusResponseFromJson(String str) => ServiceStatusResponse.fromJson(json.decode(str));

String serviceStatusResponseToJson(ServiceStatusResponse data) => json.encode(data.toJson());

class ServiceStatusResponse {
  int? status;
  String? message;
  List<ServiceStatusVO>? data;

  ServiceStatusResponse({
    this.status,
    this.message,
    this.data,
  });

  factory ServiceStatusResponse.fromJson(Map<String, dynamic> json) => ServiceStatusResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<ServiceStatusVO>.from(json["data"]!.map((x) => ServiceStatusVO.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class ServiceStatusVO {
  int? id;
  String? serviceName;
  String? serviceCost;
  String? agentName;
  String? note;
  int? status;
  DateTime? updatedAt;
  DateTime? createdAt;

  ServiceStatusVO({
    this.id,
    this.serviceName,
    this.serviceCost,
    this.agentName,
    this.note,
    this.status,
    this.updatedAt,
    this.createdAt,
  });

  factory ServiceStatusVO.fromJson(Map<String, dynamic> json) => ServiceStatusVO(
    id: json["id"],
    serviceName: json["service_name"],
    serviceCost: json["service_cost"],
    agentName: json["agent_name"],
    note: json["note"],
    status: json["status"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "service_name": serviceName,
    "service_cost": serviceCost,
    "agent_name": agentName,
    "note": note,
    "status": status,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
  };
}
