import 'package:se501_plantheon/domain/entities/activities_entities.dart';
import 'package:se501_plantheon/domain/repository/activities_repository.dart';

class GetActivitiesByMonth {
  final ActivitiesRepository repository;

  GetActivitiesByMonth(this.repository);

  Future<MonthActivitiesEntity> call({required int year, required int month}) {
    return repository.getActivitiesByMonth(year: year, month: month);
  }
}
