import 'package:se501_plantheon/domain/entities/plant_entity.dart';

abstract class PlantRepository {
  Future<List<PlantEntity>> getPlants();
}
