import 'package:se501_plantheon/data/datasources/scan_history_remote_datasource.dart';
import 'package:se501_plantheon/data/models/scan_history.model.dart';
import 'package:se501_plantheon/domain/entities/disease_entity.dart';
import 'package:se501_plantheon/domain/entities/scan_history.dart';
import 'package:se501_plantheon/domain/repository/scan_history_repository.dart';

class ScanHistoryRepositoryImpl implements ScanHistoryRepository {
  final ScanHistoryRemoteDataSource remoteDataSource;

  ScanHistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ScanHistoryEntity>> getAllScanHistory({int? size}) async {
    print('🏛️ Repository: Getting all scan history${size != null ? ' with size=$size' : ''}');
    final List<ScanHistoryModel> models =
        await remoteDataSource.getAllScanHistory(size: size);
    print('📦 Repository: Received ${models.length} scan history items');

    final entities = models.map(_mapModelToEntity).toList();
    print('🔄 Repository: Mapped to ${entities.length} entities');
    return entities;
  }

  @override
  Future<ScanHistoryEntity> createScanHistory(String diseaseId, {String? scanImage}) async {
    print('🏛️ Repository: Creating scan history for disease: $diseaseId');
    final ScanHistoryModel model =
        await remoteDataSource.createScanHistory(diseaseId, scanImage: scanImage);
    print('📦 Repository: Received scan history model with id: ${model.id}');

    final entity = _mapModelToEntity(model);
    print('🔄 Repository: Mapped to entity');
    return entity;
  }

  ScanHistoryEntity _mapModelToEntity(ScanHistoryModel model) {
    return ScanHistoryEntity(
      id: model.id,
      userId: model.userId,
      diseaseId: model.diseaseId,
      disease: DiseaseEntity(
        id: model.disease.id,
        name: model.disease.name,
        type: model.disease.type,
        description: model.disease.description,
        imageLink: model.disease.imageLink,
        createdAt: model.disease.createdAt,
        updatedAt: model.disease.updatedAt,
        className: model.disease.className,
        plantName: model.disease.plantName,
        solution: model.disease.solution,
      ),
      scanImage: model.scanImage,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
