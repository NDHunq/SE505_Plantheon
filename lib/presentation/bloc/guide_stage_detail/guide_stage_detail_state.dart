import 'package:se501_plantheon/domain/entities/guide_stage_detail_entity.dart';

abstract class GuideStageDetailState {}

class GuideStageDetailInitial extends GuideStageDetailState {}

class GuideStageDetailLoading extends GuideStageDetailState {}

class GuideStageDetailLoaded extends GuideStageDetailState {
  final GuideStageDetailEntity detail;

  GuideStageDetailLoaded({required this.detail});
}

class GuideStageDetailError extends GuideStageDetailState {
  final String message;

  GuideStageDetailError({required this.message});
}