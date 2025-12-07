abstract class GuideStageDetailEvent {}

class FetchGuideStageDetailEvent extends GuideStageDetailEvent {
  final String guideStageId;

  FetchGuideStageDetailEvent({required this.guideStageId});
}
