import 'package:se501_plantheon/data/datasources/guide_stage_remote_datasource.dart';
import 'package:se501_plantheon/data/models/guide_stage_model.dart';
import 'package:se501_plantheon/domain/entities/guide_stage_entity.dart';
import 'package:se501_plantheon/domain/entities/guide_stage_detail_entity.dart';
import 'package:se501_plantheon/domain/repository/guide_stage_repository.dart';

class GuideStageRepositoryImpl implements GuideStageRepository {
  final GuideStageRemoteDataSource remoteDataSource;

  GuideStageRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<GuideStageEntity>> getGuideStagesByPlant(String plantId) async {
    final List<GuideStageModel> models = await remoteDataSource
        .getGuideStagesByPlant(plantId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<GuideStageDetailEntity> getGuideStageDetail(
    String guideStageId,
  ) async {
    final detailModel = await remoteDataSource.getGuideStageDetail(
      guideStageId,
    );
    return detailModel.toEntity();
  }
}
