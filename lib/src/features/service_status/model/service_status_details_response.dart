// To parse this JSON data, do
//
//     final serviceStatusDetailsResponse = serviceStatusDetailsResponseFromJson(jsonString);

import 'dart:convert';

ServiceStatusDetailsResponse serviceStatusDetailsResponseFromJson(String str) => ServiceStatusDetailsResponse.fromJson(json.decode(str));

String serviceStatusDetailsResponseToJson(ServiceStatusDetailsResponse data) => json.encode(data.toJson());

class ServiceStatusDetailsResponse {
  int? status;
  String? message;
  ServiceStatusDetailsVO? data;

  ServiceStatusDetailsResponse({
    this.status,
    this.message,
    this.data,
  });

  factory ServiceStatusDetailsResponse.fromJson(Map<String, dynamic> json) => ServiceStatusDetailsResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : ServiceStatusDetailsVO.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class ServiceStatusDetailsVO {
  int? id;
  String? serviceName;
  String? serviceCost;
  String? agentName;
  String? note;
  int? status;
  List<HistoryVO>? histories;
  DateTime? createdAt;
  DateTime? updatedAt;

  ServiceStatusDetailsVO({
    this.id,
    this.serviceName,
    this.serviceCost,
    this.agentName,
    this.note,
    this.status,
    this.histories,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceStatusDetailsVO.fromJson(Map<String, dynamic> json) => ServiceStatusDetailsVO(
    id: json["id"],
    serviceName: json["service_name"],
    serviceCost: json["service_cost"],
    agentName: json["agent_name"],
    note: json["note"],
    status: json["status"],
    histories: json["histories"] == null ? [] : List<HistoryVO>.from(json["histories"]!.map((x) => HistoryVO.fromJson(x))),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "service_name": serviceName,
    "service_cost": serviceCost,
    "agent_name": agentName,
    "note": note,
    "status": status,
    "histories": histories == null ? [] : List<dynamic>.from(histories!.map((x) => x.toJson())),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class HistoryVO {
  int? id;
  int? status;
  String? note;
  ChangedByVO? changedBy;
  DateTime? createdAt;

  HistoryVO({
    this.id,
    this.status,
    this.note,
    this.changedBy,
    this.createdAt,
  });

  factory HistoryVO.fromJson(Map<String, dynamic> json) => HistoryVO(
    id: json["id"],
    status: json["status"],
    note: json["note"],
    changedBy: json["changed_by"] == null ? null : ChangedByVO.fromJson(json["changed_by"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "note": note,
    "changed_by": changedBy?.toJson(),
    "created_at": createdAt?.toIso8601String(),
  };
}

class ChangedByVO {
  dynamic id;
  dynamic name;

  ChangedByVO({
    this.id,
    this.name,
  });

  factory ChangedByVO.fromJson(Map<String, dynamic> json) => ChangedByVO(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
