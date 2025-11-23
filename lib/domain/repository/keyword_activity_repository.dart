import 'package:se501_plantheon/domain/entities/keyword_activity_entity.dart';

abstract class KeywordActivityRepository {
  Future<List<KeywordActivityEntity>> getKeywordActivitiesByDiseaseId({
    required String diseaseId,
  });
}
