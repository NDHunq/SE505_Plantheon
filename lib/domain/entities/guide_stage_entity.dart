class GuideStageEntity {
  final String id;
  final String plantId;
  final String stageTitle;
  final String description;
  final int startDayOffset;
  final int endDayOffset;
  final String imageUrl;
  final DateTime createdAt;

  GuideStageEntity({
    required this.id,
    required this.plantId,
    required this.stageTitle,
    required this.description,
    required this.startDayOffset,
    required this.endDayOffset,
    required this.imageUrl,
    required this.createdAt,
  });
}
