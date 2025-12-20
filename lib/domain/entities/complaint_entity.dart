class ComplaintEntity {
  final String id;
  final String userId;
  final String targetId;
  final String targetType;
  final String category;
  final String? content;
  final String imageUrl;
  final String status;
  final String predictedDiseaseId;
  final String? userSuggestedDiseaseId;
  final double confidenceScore;
  final bool isVerified;
  final String? verifiedDiseaseId;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ComplaintEntity({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.targetType,
    required this.category,
    this.content,
    required this.imageUrl,
    required this.status,
    required this.predictedDiseaseId,
    this.userSuggestedDiseaseId,
    required this.confidenceScore,
    required this.isVerified,
    this.verifiedDiseaseId,
    this.verifiedBy,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
