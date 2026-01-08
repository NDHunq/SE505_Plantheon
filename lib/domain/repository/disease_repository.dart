import 'package:se501_plantheon/domain/entities/disease_entity.dart';

abstract class DiseaseRepository {
  Future<DiseaseEntity> getDisease(String diseaseId);
  Future<List<DiseaseEntity>> getAllDiseases({String? search});
}
