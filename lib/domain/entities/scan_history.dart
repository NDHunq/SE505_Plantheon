import 'package:se501_plantheon/domain/entities/disease_entity.dart';

class ScanHistoryEntity {
  final String id;
  final String userId;
  final String diseaseId;
  final DiseaseEntity disease;
  final String? scanImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScanHistoryEntity({
    required this.id,
    required this.userId,
    required this.diseaseId,
    required this.disease,
    this.scanImage,
    required this.createdAt,
    required this.updatedAt,
  });
}
