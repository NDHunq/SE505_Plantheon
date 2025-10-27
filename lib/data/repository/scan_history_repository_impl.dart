import 'package:se501_plantheon/data/datasources/scan_history_remote_datasource.dart';
import 'package:se501_plantheon/data/models/scan_history.model.dart';
import 'package:se501_plantheon/domain/entities/disease_entity.dart';
import 'package:se501_plantheon/domain/entities/scan_history.dart';
import 'package:se501_plantheon/domain/repository/scan_history_repository.dart';

class ScanHistoryRepositoryImpl implements ScanHistoryRepository {
  final ScanHistoryRemoteDataSource remoteDataSource;

  ScanHistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ScanHistoryEntity>> getAllScanHistory() async {
    print('🏛️ Repository: Getting all scan history');
    final List<ScanHistoryModel> models = await remoteDataSource
        .getAllScanHistory();
    print('📦 Repository: Received ${models.length} scan history items');

    final entities = models.map((model) => _mapModelToEntity(model)).toList();
    print('🔄 Repository: Mapped to entities');
    return entities;
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
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
