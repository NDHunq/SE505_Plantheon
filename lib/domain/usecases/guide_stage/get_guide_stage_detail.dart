import 'package:se501_plantheon/domain/entities/guide_stage_detail_entity.dart';
import 'package:se501_plantheon/domain/repository/guide_stage_repository.dart';

class GetGuideStageDetail {
  final GuideStageRepository repository;

  GetGuideStageDetail({required this.repository});

  Future<GuideStageDetailEntity> call(String guideStageId) async {
    return repository.getGuideStageDetail(guideStageId);
  }
}
