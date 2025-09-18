import 'dart:convert';

AvailableAgentsResponse availableAgentsResponseFromJson(String str) =>
    AvailableAgentsResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String availableAgentsResponseToJson(AvailableAgentsResponse data) =>
    json.encode(data.toJson());

class AvailableAgentsResponse {
  final int? status;
  final String? message;
  final List<AgentDataVO>? data;

  const AvailableAgentsResponse({this.status, this.message, this.data});

  factory AvailableAgentsResponse.fromJson(Map<String, dynamic> json) {
    return AvailableAgentsResponse(
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse('${json['status']}'),
      message: json['message'] as String?,
      data: (json['data'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map(AgentDataVO.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'status': status,
      'message': message,
      'data': data?.map((x) => x.toJson()).toList(),
    };
    map.removeWhere((_, v) => v == null);
    return map;
  }
}

class AgentDataVO {
  final int? id;
  final String? name;
  final String? rating;
  final String? location;
  final bool? canRequest;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  const AgentDataVO({
    this.id,
    this.name,
    this.rating,
    this.location,
    this.canRequest,
    this.updatedAt,
    this.createdAt,
  });

  factory AgentDataVO.fromJson(Map<String, dynamic> json) {
    return AgentDataVO(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: json['name'] as String?,
      rating: json['rating']?.toString(),
      location: json['location'] as String?,
      canRequest: json['canRequest'] is bool
          ? json['canRequest'] as bool
          : (json['canRequest']?.toString().toLowerCase() == 'true'
                ? true
                : (json['canRequest']?.toString().toLowerCase() == 'false'
                      ? false
                      : null)),
      updatedAt: _parseDateTime(json['updated_at']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'rating': rating,
      'location': location,
      'canRequest': canRequest,
      'updated_at': updatedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
    map.removeWhere((_, v) => v == null);
    return map;
  }
}

/// Safe DateTime parser for common API shapes.
DateTime? _parseDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  if (v is int) {
    final isMillis = v.abs() > 1000000000000;
    try {
      return DateTime.fromMillisecondsSinceEpoch(
        isMillis ? v : v * 1000,
        isUtc: false,
      );
    } catch (_) {
      return null;
    }
  }
  return null;
}
