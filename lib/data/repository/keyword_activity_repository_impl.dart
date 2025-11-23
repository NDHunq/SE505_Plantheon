import 'package:se501_plantheon/data/datasources/keyword_activities_remote_datasource.dart';
import 'package:se501_plantheon/domain/entities/keyword_activity_entity.dart';
import 'package:se501_plantheon/domain/repository/keyword_activity_repository.dart';

class KeywordActivityRepositoryImpl implements KeywordActivityRepository {
  final KeywordActivitiesRemoteDataSource remoteDataSource;

  KeywordActivityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<KeywordActivityEntity>> getKeywordActivitiesByDiseaseId({
    required String diseaseId,
  }) async {
    final response = await remoteDataSource.getKeywordActivitiesByDiseaseId(
      diseaseId: diseaseId,
    );
    return response.data.map((model) => model.toEntity()).toList();
  }
}
