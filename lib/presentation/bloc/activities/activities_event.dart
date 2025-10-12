import 'package:se501_plantheon/data/models/activities_models.dart';

abstract class ActivitiesEvent {}

class FetchActivitiesByMonth extends ActivitiesEvent {
  final int year;
  final int month;

  FetchActivitiesByMonth({required this.year, required this.month});
}

class FetchActivitiesByDay extends ActivitiesEvent {
  final String dateIso; // YYYY-MM-DD

  FetchActivitiesByDay({required this.dateIso});
}

class CreateActivityEvent extends ActivitiesEvent {
  final CreateActivityRequestModel request;

  CreateActivityEvent({required this.request});
}

class UpdateActivityEvent extends ActivitiesEvent {
  final String id;
  final CreateActivityRequestModel request;

  UpdateActivityEvent({required this.id, required this.request});
}
