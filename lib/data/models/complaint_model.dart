class ScanComplaintModel {
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

  ScanComplaintModel({
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

  factory ScanComplaintModel.fromJson(Map<String, dynamic> json) {
    return ScanComplaintModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      targetId: json['target_id'] as String? ?? '',
      targetType: json['target_type'] as String? ?? '',
      category: json['category'] as String? ?? '',
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String? ?? '',
      status: json['status'] as String? ?? '',
      predictedDiseaseId: json['predicted_disease_id'] as String? ?? '',
      userSuggestedDiseaseId: json['user_suggested_disease_id'] as String?,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] as bool? ?? false,
      verifiedDiseaseId: json['verified_disease_id'] as String?,
      verifiedBy: json['verified_by'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'target_id': targetId,
      'target_type': targetType,
      'category': category,
      if (content != null) 'content': content,
      'image_url': imageUrl,
      'status': status,
      'predicted_disease_id': predictedDiseaseId,
      if (userSuggestedDiseaseId != null)
        'user_suggested_disease_id': userSuggestedDiseaseId,
      'confidence_score': confidenceScore,
      'is_verified': isVerified,
      if (verifiedDiseaseId != null) 'verified_disease_id': verifiedDiseaseId,
      if (verifiedBy != null) 'verified_by': verifiedBy,
      if (verifiedAt != null) 'verified_at': verifiedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class SubmitScanComplaintRequestModel {
  final String targetType;
  final String predictedDiseaseId;
  final String? userSuggestedDiseaseId;
  final double confidenceScore;
  final String category;
  final String imageUrl;
  final String? content;

  SubmitScanComplaintRequestModel({
    this.targetType = 'SCAN',
    required this.predictedDiseaseId,
    this.userSuggestedDiseaseId,
    required this.confidenceScore,
    required this.category,
    required this.imageUrl,
    this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'target_type': targetType,
      'predicted_disease_id': predictedDiseaseId,
      if (userSuggestedDiseaseId != null)
        'user_suggested_disease_id': userSuggestedDiseaseId,
      'confidence_score': confidenceScore,
      'category': category,
      'image_url': imageUrl,
      if (content != null) 'content': content,
    };
  }
}

class SubmitScanComplaintResponseModel {
  final String message;
  final ScanComplaintModel data;

  SubmitScanComplaintResponseModel({
    required this.message,
    required this.data,
  });

  factory SubmitScanComplaintResponseModel.fromJson(
      Map<String, dynamic> json) {
    return SubmitScanComplaintResponseModel(
      message: json['message'] as String? ?? '',
      data: ScanComplaintModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}
