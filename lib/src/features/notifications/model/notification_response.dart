import 'dart:convert';

NotificationResponse notificationResponseFromJson(String str) => NotificationResponse.fromJson(json.decode(str));

String notificationResponseToJson(NotificationResponse data) => json.encode(data.toJson());

class NotificationResponse {
  int? status;
  String? message;
  List<NotificationVO>? data;

  NotificationResponse({
    this.status,
    this.message,
    this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) => NotificationResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<NotificationVO>.from(json["data"]!.map((x) => NotificationVO.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class NotificationVO {
  int? id;
  int? userId;
  String? title;
  String? body;
  String? deliveryStatus;
  String? readStatus;
  DateTime? createdAt;
  DateTime? updatedAt;

  NotificationVO({
    this.id,
    this.userId,
    this.title,
    this.body,
    this.deliveryStatus,
    this.readStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationVO.fromJson(Map<String, dynamic> json) => NotificationVO(
    id: json["id"],
    userId: json["user_id"],
    title: json["title"],
    body: json["body"],
    deliveryStatus: json["delivery_status"],
    readStatus: json["read_status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "title": title,
    "body": body,
    "delivery_status": deliveryStatus,
    "read_status": readStatus,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
