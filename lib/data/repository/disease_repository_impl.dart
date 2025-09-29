import 'package:se501_plantheon/data/datasources/disease_remote_datasource.dart';
import 'package:se501_plantheon/data/models/diseases.model.dart';
import 'package:se501_plantheon/domain/entities/disease_entity.dart';
import 'package:se501_plantheon/domain/repository/disease_repository.dart';

class DiseaseRepositoryImpl implements DiseaseRepository {
  final DiseaseRemoteDataSource remoteDataSource;

  DiseaseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DiseaseEntity> getDisease(String diseaseId) async {
    print('🏛️ Repository: Getting disease with ID: $diseaseId');
    final DiseaseModel diseaseModel = await remoteDataSource.getDisease(
      diseaseId,
    );
    print('📦 Repository: Received model: ${diseaseModel.name}');
    final entity = _mapModelToEntity(diseaseModel);
    print('🔄 Repository: Mapped to entity: ${entity.name}');
    return entity;
  }

  DiseaseEntity _mapModelToEntity(DiseaseModel model) {
    return DiseaseEntity(
      id: model.id,
      name: model.name,
      type: model.type,
      description: model.description,
      imageLink: model.imageLink,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      className: model.className,
      plantName: model.plantName,
      solution: model.solution,
    );
  }
}
