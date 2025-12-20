import 'package:se501_plantheon/domain/entities/complaint_entity.dart';
import 'package:se501_plantheon/domain/entities/complaint_history_entity.dart';

abstract class ComplaintRepository {
  Future<ComplaintEntity> submitScanComplaint({
    required String predictedDiseaseId,
    required double confidenceScore,
    required String category,
    required String imageUrl,
    String? userSuggestedDiseaseId,
    String? content,
  });

  Future<void> submitComplaint(ComplaintEntity complaint);

  Future<List<ComplaintHistoryEntity>> getComplaintsAboutMe({
    int page,
    int limit,
  });
}
