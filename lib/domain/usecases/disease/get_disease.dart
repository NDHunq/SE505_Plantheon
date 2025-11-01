import 'package:se501_plantheon/domain/entities/disease_entity.dart';
import 'package:se501_plantheon/domain/repository/disease_repository.dart';

class GetDisease {
  final DiseaseRepository repository;

  GetDisease({required this.repository});

  Future<DiseaseEntity> call(String diseaseId) async {
    final entity = await repository.getDisease(diseaseId);
    return entity;
  }
}
