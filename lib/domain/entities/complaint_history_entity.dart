/// Reporter information in a complaint
class ComplaintReporter {
  final String id;
  final String userName;
  final String avatar;

  ComplaintReporter({
    required this.id,
    required this.userName,
    required this.avatar,
  });
}

/// Target (post or comment) information in a complaint
class ComplaintTarget {
  final String id;
  final String content;
  final String userId;
  final String userName;
  final String avatar;
  final bool isDeleted;
  final DateTime createdAt;

  ComplaintTarget({
    required this.id,
    required this.content,
    required this.userId,
    required this.userName,
    required this.avatar,
    required this.isDeleted,
    required this.createdAt,
  });
}

/// Full complaint history entity containing all complaint details
class ComplaintHistoryEntity {
  final String id;
  final ComplaintReporter reporter;
  final ComplaintTarget target;
  final String targetType; // "POST" or "COMMENT"
  final String category; // "HARASSMENT", "SPAM", etc.
  final String content;
  final String status; // "PENDING", "RESOLVED", "REJECTED"
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ComplaintHistoryEntity({
    required this.id,
    required this.reporter,
    required this.target,
    required this.targetType,
    required this.category,
    required this.content,
    required this.status,
    this.resolvedAt,
    this.resolvedBy,
    required this.createdAt,
    required this.updatedAt,
  });
}
