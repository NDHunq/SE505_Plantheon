abstract class GuideStageEvent {}

class FetchGuideStagesEvent extends GuideStageEvent {
  final String plantId;

  FetchGuideStagesEvent({required this.plantId});
}
