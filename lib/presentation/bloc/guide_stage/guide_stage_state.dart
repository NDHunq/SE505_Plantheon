import 'package:se501_plantheon/domain/entities/guide_stage_entity.dart';

abstract class GuideStageState {}

class GuideStageInitial extends GuideStageState {}

class GuideStageLoading extends GuideStageState {}

class GuideStageLoaded extends GuideStageState {
  final List<GuideStageEntity> stages;

  GuideStageLoaded({required this.stages});
}

class GuideStageError extends GuideStageState {
  final String message;

  GuideStageError({required this.message});
}