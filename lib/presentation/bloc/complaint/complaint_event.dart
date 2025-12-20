abstract class ComplaintEvent {}

class SubmitScanComplaintEvent extends ComplaintEvent {
  final String predictedDiseaseId;
  final double confidenceScore;
  final String category;
  final String imageUrl;
  final String? userSuggestedDiseaseId;
  final String? content;

  SubmitScanComplaintEvent({
    required this.predictedDiseaseId,
    required this.confidenceScore,
    required this.category,
    required this.imageUrl,
    this.userSuggestedDiseaseId,
    this.content,
  });
}
