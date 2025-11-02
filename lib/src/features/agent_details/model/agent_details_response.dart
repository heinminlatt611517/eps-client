// agent_details_response.dart
import 'dart:convert';

AgentDetailsResponse agentDetailsResponseFromJson(String str) =>
    AgentDetailsResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String agentDetailsResponseToJson(AgentDetailsResponse data) =>
    json.encode(data.toJson());

class AgentDetailsResponse {
  final int? status;
  final String? message;
  final AgentDetail? data;

  const AgentDetailsResponse({this.status, this.message, this.data});

  factory AgentDetailsResponse.fromJson(Map<String, dynamic> json) {
    return AgentDetailsResponse(
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse('${json['status']}'),
      message: json['message'] as String?,
      data: (json['data'] is Map<String, dynamic>)
          ? AgentDetail.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
    map.removeWhere((_, v) => v == null);
    return map;
  }
}

class AgentDetail {
  final int? id;
  final dynamic rating;
  final String? agentId;
  final String? name;
  final String? email;
  final String? bizName;
  final String? phone;
  final String? location;
  List<ServiceVO>? services;
  List<ReviewVO>? reviews;

  AgentDetail({
    this.id,
    this.rating,
    this.agentId,
    this.name,
    this.email,
    this.bizName,
    this.phone,
    this.location,
    this.services,
    this.reviews
  });

  factory AgentDetail.fromJson(Map<String, dynamic> json) {
    return AgentDetail(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      rating: json['rating']?.toString(),
      agentId: json['agent_id']?.toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      bizName: json['biz_name'] as String?,
      phone: json['phone']?.toString(),
      location: json['location'] as String?,
      services: json["services"] == null ? [] : List<ServiceVO>.from(json["services"]!.map((x) => ServiceVO.fromJson(x))),
      reviews: json["reviews"] == null ? [] : List<ReviewVO>.from(json["reviews"]!.map((x) => ReviewVO.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'rating' : rating,
      'agent_id': agentId,
      'name': name,
      'email': email,
      'biz_name': bizName,
      'phone': phone,
      'location': location,
      "services": services == null ? [] : List<dynamic>.from(services!.map((x) => x.toJson())),
      "reviews": reviews == null ? [] : List<dynamic>.from(reviews!.map((x) => x)),
    };
    map.removeWhere((_, v) => v == null);
    return map;
  }

  AgentDetail copyWith({
    int? id,
    String? agentId,
    String? name,
    String? email,
    String? bizName,
    String? phone,
    String? location,
  }) {
    return AgentDetail(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      name: name ?? this.name,
      email: email ?? this.email,
      bizName: bizName ?? this.bizName,
      phone: phone ?? this.phone,
      location: location ?? this.location,
    );
  }
}
class ServiceVO {
  int? id;
  String? title;
  String? category;
  String? subcategory;
  String? detail;
  String? duration;
  String? cost;
  DateTime? createdAt;

  ServiceVO({
    this.id,
    this.title,
    this.category,
    this.subcategory,
    this.detail,
    this.duration,
    this.cost,
    this.createdAt,
  });

  factory ServiceVO.fromJson(Map<String, dynamic> json) => ServiceVO(
    id: json["id"],
    title: json["title"],
    category: json["category"],
    subcategory: json["subcategory"],
    detail: json["detail"],
    duration: json["duration"],
    cost: json["cost"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "category": category,
    "subcategory": subcategory,
    "detail": detail,
    "duration": duration,
    "cost": cost,
    "created_at": createdAt?.toIso8601String(),
  };
}

class ReviewVO {
  int? id;
  dynamic rating;
  String? comment;
  String? customerName;
  String? customerEmail;
  DateTime? createdAt;

  ReviewVO({
    this.id,
    this.rating,
    this.comment,
    this.customerName,
    this.customerEmail,
    this.createdAt,
  });

  factory ReviewVO.fromJson(Map<String, dynamic> json) => ReviewVO(
    id: json["id"],
    rating: json["rating"],
    comment: json["comment"],
    customerName: json["customer_name"],
    customerEmail: json["customer_email"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "rating": rating,
    "comment": comment,
    "customer_name": customerName,
    "customer_email": customerEmail,
    "created_at": createdAt?.toIso8601String(),
  };
}