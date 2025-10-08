import 'package:se501_plantheon/data/datasources/activities_remote_datasource.dart';
import 'package:se501_plantheon/domain/entities/activities_entities.dart';
import 'package:se501_plantheon/domain/repository/activities_repository.dart';
import 'package:se501_plantheon/data/models/activities_models.dart';

class ActivitiesRepositoryImpl implements ActivitiesRepository {
  final ActivitiesRemoteDataSource remoteDataSource;

  ActivitiesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<MonthActivitiesEntity> getActivitiesByMonth({
    required int year,
    required int month,
  }) async {
    final model = await remoteDataSource.getActivitiesByMonth(
      year: year,
      month: month,
    );
    return model.toEntity();
  }

  @override
  Future<DayActivitiesOfDayEntity> getActivitiesByDay({
    required String dateIso,
  }) async {
    print('[ActivitiesRepository] getActivitiesByDay date=$dateIso');
    final model = await remoteDataSource.getActivitiesByDay(dateIso: dateIso);
    print('[ActivitiesRepository] mapped model count=${model.count}');
    return model.toEntity();
  }

  @override
  Future<CreateActivityResponseModel> createActivity({
    required CreateActivityRequestModel request,
  }) async {
    print('[ActivitiesRepository] createActivity title=${request.title}');
    final response = await remoteDataSource.createActivity(request: request);
    print('[ActivitiesRepository] activity created with id=${response.id}');
    return response;
  }
}
