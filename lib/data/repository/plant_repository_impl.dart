import 'package:se501_plantheon/data/datasources/plant_remote_datasource.dart';
import 'package:se501_plantheon/data/models/plant_model.dart';
import 'package:se501_plantheon/domain/entities/plant_entity.dart';
import 'package:se501_plantheon/domain/repository/plant_repository.dart';

class PlantRepositoryImpl implements PlantRepository {
  final PlantRemoteDataSource remoteDataSource;

  PlantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PlantEntity>> getPlants() async {
    final List<PlantModel> models = await remoteDataSource.getPlants();
    return models.map(_mapModelToEntity).toList();
  }

  PlantEntity _mapModelToEntity(PlantModel model) {
    return PlantEntity(
      id: model.id,
      name: model.name,
      description: model.description,
      imageUrl: model.imageUrl,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
