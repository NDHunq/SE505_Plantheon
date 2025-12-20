import 'package:se501_plantheon/domain/entities/complaint_entity.dart';

abstract class ComplaintRepository {
  Future<ComplaintEntity> submitScanComplaint({
    required String predictedDiseaseId,
    required double confidenceScore,
    required String category,
    required String imageUrl,
    String? userSuggestedDiseaseId,
    String? content,
  });
}
