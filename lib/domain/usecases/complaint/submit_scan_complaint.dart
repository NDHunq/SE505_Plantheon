import 'package:se501_plantheon/domain/entities/complaint_entity.dart';
import 'package:se501_plantheon/domain/repository/complaint_repository.dart';

class SubmitScanComplaint {
  final ComplaintRepository repository;

  SubmitScanComplaint({required this.repository});

  Future<ComplaintEntity> call({
    required String predictedDiseaseId,
    required double confidenceScore,
    required String category,
    required String imageUrl,
    String? userSuggestedDiseaseId,
    String? content,
  }) async {
    final entity = await repository.submitScanComplaint(
      predictedDiseaseId: predictedDiseaseId,
      confidenceScore: confidenceScore,
      category: category,
      imageUrl: imageUrl,
      userSuggestedDiseaseId: userSuggestedDiseaseId,
      content: content,
    );
    return entity;
  }
}
