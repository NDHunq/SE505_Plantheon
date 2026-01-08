import 'package:se501_plantheon/domain/entities/disease_entity.dart';
import 'package:se501_plantheon/domain/repository/disease_repository.dart';

class GetAllDiseases {
  final DiseaseRepository repository;

  GetAllDiseases({required this.repository});

  Future<List<DiseaseEntity>> call({String? search}) async {
    return await repository.getAllDiseases(search: search);
  }
}
