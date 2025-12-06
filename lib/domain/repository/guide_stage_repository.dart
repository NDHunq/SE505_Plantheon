import 'package:se501_plantheon/domain/entities/guide_stage_entity.dart';
import 'package:se501_plantheon/domain/entities/guide_stage_detail_entity.dart';

abstract class GuideStageRepository {
  Future<List<GuideStageEntity>> getGuideStagesByPlant(String plantId);
  Future<GuideStageDetailEntity> getGuideStageDetail(String guideStageId);
}
