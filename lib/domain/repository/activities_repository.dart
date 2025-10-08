import 'package:se501_plantheon/domain/entities/activities_entities.dart';
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
}
