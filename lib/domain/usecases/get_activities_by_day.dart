import 'package:se501_plantheon/domain/entities/activities_entities.dart';
import 'package:se501_plantheon/domain/repository/activities_repository.dart';

class GetActivitiesByDay {
  final ActivitiesRepository repository;

  GetActivitiesByDay(this.repository);

  Future<DayActivitiesOfDayEntity> call({required String dateIso}) {
    print('[GetActivitiesByDay] Calling repository with date=$dateIso');
    return repository.getActivitiesByDay(dateIso: dateIso);
  }
}
