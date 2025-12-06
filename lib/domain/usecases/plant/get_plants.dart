import 'package:se501_plantheon/domain/entities/plant_entity.dart';
import 'package:se501_plantheon/domain/repository/plant_repository.dart';

class GetPlants {
  final PlantRepository repository;

  GetPlants({required this.repository});

  Future<List<PlantEntity>> call() async {
    return repository.getPlants();
  }
}
