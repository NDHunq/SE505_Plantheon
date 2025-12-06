import 'package:se501_plantheon/domain/entities/guide_stage_entity.dart';
import 'package:se501_plantheon/domain/entities/sub_guide_stage_entity.dart';

class GuideStageDetailEntity extends GuideStageEntity {
  final List<SubGuideStageEntity> subGuideStages;

  GuideStageDetailEntity({
    required super.id,
    required super.plantId,
    required super.stageTitle,
    required super.description,
    required super.startDayOffset,
    required super.endDayOffset,
    required super.imageUrl,
    required super.createdAt,
    required this.subGuideStages,
  });
}
