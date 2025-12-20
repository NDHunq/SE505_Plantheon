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

class SubmitComplaintEvent extends ComplaintEvent {
  final String targetId;
  final String targetType;
  final String category;
  final String content;

  SubmitComplaintEvent({
    required this.targetId,
    required this.targetType,
    required this.category,
    required this.content,
  });
}

class FetchComplaintsAboutMeEvent extends ComplaintEvent {
  final int page;
  final int limit;

  FetchComplaintsAboutMeEvent({this.page = 1, this.limit = 10});
}
