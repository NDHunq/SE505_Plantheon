import 'package:se501_plantheon/domain/entities/guide_stage_entity.dart';
import 'package:se501_plantheon/domain/repository/guide_stage_repository.dart';

class GetGuideStagesByPlant {
  final GuideStageRepository repository;

  GetGuideStagesByPlant({required this.repository});

  Future<List<GuideStageEntity>> call(String plantId) async {
    return repository.getGuideStagesByPlant(plantId);
  }
}
