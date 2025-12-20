import 'package:se501_plantheon/domain/entities/complaint_history_entity.dart';

class ComplaintReporterModel extends ComplaintReporter {
  ComplaintReporterModel({
    required super.id,
    required super.userName,
    required super.avatar,
  });

  factory ComplaintReporterModel.fromJson(Map<String, dynamic> json) {
    return ComplaintReporterModel(
      id: json['id'] ?? '',
      userName: json['user_name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}

class ComplaintTargetModel extends ComplaintTarget {
  ComplaintTargetModel({
    required super.id,
    required super.content,
    required super.userId,
    required super.userName,
    required super.avatar,
    required super.isDeleted,
    required super.createdAt,
  });

  factory ComplaintTargetModel.fromJson(Map<String, dynamic> json) {
    return ComplaintTargetModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      avatar: json['avatar'] ?? '',
      isDeleted: json['is_deleted'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class ComplaintHistoryModel extends ComplaintHistoryEntity {
  ComplaintHistoryModel({
    required super.id,
    required super.reporter,
    required super.target,
    required super.targetType,
    required super.category,
    required super.content,
    required super.status,
    super.resolvedAt,
    super.resolvedBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ComplaintHistoryModel.fromJson(Map<String, dynamic> json) {
    return ComplaintHistoryModel(
      id: json['id'] ?? '',
      reporter: ComplaintReporterModel.fromJson(json['reporter'] ?? {}),
      target: ComplaintTargetModel.fromJson(json['target'] ?? {}),
      targetType: json['target_type'] ?? '',
      category: json['category'] ?? '',
      content: json['content'] ?? '',
      status: json['status'] ?? '',
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      resolvedBy: json['resolved_by'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}

/// Response wrapper for complaints list
class ComplaintsAboutMeResponse {
  final List<ComplaintHistoryModel> complaints;
  final int total;
  final int page;
  final int limit;

  ComplaintsAboutMeResponse({
    required this.complaints,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory ComplaintsAboutMeResponse.fromJson(Map<String, dynamic> json) {
    // API returns: {"data": [...complaints...], "total": 2}
    // Where "data" is directly the list of complaints
    final dynamic data = json['data'];

    List<dynamic> complaintsList;
    int total;
    int page;
    int limit;

    if (data is List) {
      // data is directly the list of complaints
      complaintsList = data;
      total = _parseInt(json['total']) ?? data.length;
      page = _parseInt(json['page']) ?? 1;
      limit = _parseInt(json['limit']) ?? 10;
    } else if (data is Map<String, dynamic>) {
      // data is an object containing complaints, total, page, limit
      complaintsList = data['complaints'] is List ? data['complaints'] : [];
      total = _parseInt(data['total']) ?? complaintsList.length;
      page = _parseInt(data['page']) ?? 1;
      limit = _parseInt(data['limit']) ?? 10;
    } else {
      // fallback
      complaintsList = [];
      total = 0;
      page = 1;
      limit = 10;
    }

    return ComplaintsAboutMeResponse(
      complaints: complaintsList
          .map((e) => ComplaintHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: total,
      page: page,
      limit: limit,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
