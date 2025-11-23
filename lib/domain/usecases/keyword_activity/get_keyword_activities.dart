import 'package:se501_plantheon/domain/entities/keyword_activity_entity.dart';
import 'package:se501_plantheon/domain/repository/keyword_activity_repository.dart';

class GetKeywordActivities {
  final KeywordActivityRepository repository;

  GetKeywordActivities(this.repository);

  Future<List<KeywordActivityEntity>> call({required String diseaseId}) async {
    return await repository.getKeywordActivitiesByDiseaseId(
      diseaseId: diseaseId,
    );
  }
}
