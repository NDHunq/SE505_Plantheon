import 'package:se501_plantheon/data/datasources/activities_remote_datasource.dart';
import 'package:se501_plantheon/domain/entities/activities_entities.dart';
import 'package:se501_plantheon/domain/entities/financial_entities.dart';
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

  @override
  Future<CreateActivityResponseModel> updateActivity({
    required String id,
    required CreateActivityRequestModel request,
  }) async {
    print(
      '[ActivitiesRepository] updateActivity id=$id, title=${request.title}',
    );
    final response = await remoteDataSource.updateActivity(
      id: id,
      request: request,
    );
    print('[ActivitiesRepository] activity updated with id=${response.id}');
    return response;
  }

  @override
  Future<void> deleteActivity({required String id}) async {
    print('[ActivitiesRepository] deleteActivity id=$id');
    await remoteDataSource.deleteActivity(id: id);
  }

  @override
  Future<MonthlyFinancialEntity> getMonthlyFinancial({
    required int year,
    required int month,
  }) async {
    print(
      '[ActivitiesRepository] getMonthlyFinancial year=$year, month=$month',
    );
    final response = await remoteDataSource.getMonthlyFinancial(
      year: year,
      month: month,
    );
    return response.toEntity();
  }

  @override
  Future<AnnualFinancialEntity> getAnnualFinancial({required int year}) async {
    print('[ActivitiesRepository] getAnnualFinancial year=$year');
    final response = await remoteDataSource.getAnnualFinancial(year: year);
    return response.toEntity();
  }

  @override
  Future<MultiYearFinancialEntity> getMultiYearFinancial({
    required int startYear,
    required int endYear,
  }) async {
    print(
      '[ActivitiesRepository] getMultiYearFinancial startYear=$startYear, endYear=$endYear',
    );
    final response = await remoteDataSource.getMultiYearFinancial(
      startYear: startYear,
      endYear: endYear,
    );
    return response.toEntity();
  }
}
