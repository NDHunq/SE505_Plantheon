import 'package:se501_plantheon/data/models/diseases.model.dart';

class ScanHistoryModel {
  final String id;
  final String userId;
  final String diseaseId;
  final DiseaseModel disease;
  final String? scanImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScanHistoryModel({
    required this.id,
    required this.userId,
    required this.diseaseId,
    required this.disease,
    this.scanImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      diseaseId: json['disease_id'] as String? ?? '',
      disease: DiseaseModel.fromJson(json['disease'] as Map<String, dynamic>),
      scanImage: json['scan_image'] as String?,
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
      'disease_id': diseaseId,
      'disease': disease.toJson(),
      if (scanImage != null) 'scan_image': scanImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class GetAllScanHistoryResponseModel {
  final List<ScanHistoryModel> scanHistories;
  final int total;

  GetAllScanHistoryResponseModel({
    required this.scanHistories,
    required this.total,
  });

  factory GetAllScanHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final scanHistoriesList = data['scan_histories'] as List;

    return GetAllScanHistoryResponseModel(
      scanHistories: scanHistoriesList
          .map(
            (item) => ScanHistoryModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      total: data['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'scan_histories': scanHistories.map((item) => item.toJson()).toList(),
        'total': total,
      },
    };
  }
}

class CreateScanHistoryRequestModel {
  final String diseaseId;
  final String? scanImage;

  CreateScanHistoryRequestModel({
    required this.diseaseId,
    this.scanImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'disease_id': diseaseId,
      if (scanImage != null) 'scan_image': scanImage,
    };
  }
}

class CreateScanHistoryResponseModel {
  final ScanHistoryModel scanHistory;

  CreateScanHistoryResponseModel({required this.scanHistory});

  factory CreateScanHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return CreateScanHistoryResponseModel(
      scanHistory: ScanHistoryModel.fromJson(data),
    );
  }
}
