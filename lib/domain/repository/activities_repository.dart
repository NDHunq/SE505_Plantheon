import 'package:se501_plantheon/domain/entities/activities_entities.dart';
import 'package:se501_plantheon/domain/entities/financial_entities.dart';
import 'package:se501_plantheon/data/models/activities_models.dart';

abstract class ActivitiesRepository {
  Future<MonthActivitiesEntity> getActivitiesByMonth({
    required int year,
    required int month,
  });

  Future<DayActivitiesOfDayEntity> getActivitiesByDay({
    required String dateIso,
  });

  Future<CreateActivityResponseModel> createActivity({
    required CreateActivityRequestModel request,
  });

  Future<CreateActivityResponseModel> updateActivity({
    required String id,
    required CreateActivityRequestModel request,
  });

  Future<void> deleteActivity({required String id});

  Future<MonthlyFinancialEntity> getMonthlyFinancial({
    required int year,
    required int month,
  });

  Future<AnnualFinancialEntity> getAnnualFinancial({required int year});

  Future<MultiYearFinancialEntity> getMultiYearFinancial({
    required int startYear,
    required int endYear,
  });
}
