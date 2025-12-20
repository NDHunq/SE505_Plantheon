class ComplaintEntity {
  final String targetId;
  final String targetType; // "POST" or "COMMENT"
  final String category;
  final String content;

  ComplaintEntity({
    required this.targetId,
    required this.targetType,
    required this.category,
    required this.content,
  });
}
