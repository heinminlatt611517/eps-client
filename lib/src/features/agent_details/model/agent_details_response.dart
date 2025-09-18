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
  final String? agentId;
  final String? name;
  final String? email;
  final String? bizName;
  final String? phone;
  final String? location;

  const AgentDetail({
    this.id,
    this.agentId,
    this.name,
    this.email,
    this.bizName,
    this.phone,
    this.location,
  });

  factory AgentDetail.fromJson(Map<String, dynamic> json) {
    return AgentDetail(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      agentId: json['agent_id']?.toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      bizName: json['biz_name'] as String?,
      phone: json['phone']?.toString(),
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'agent_id': agentId,
      'name': name,
      'email': email,
      'biz_name': bizName,
      'phone': phone,
      'location': location,
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
