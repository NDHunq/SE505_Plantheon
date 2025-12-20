import 'package:se501_plantheon/data/models/activities_models.dart';

abstract class ActivitiesEvent {}

class FetchActivitiesByMonth extends ActivitiesEvent {
  final int year;
  final int month;

  FetchActivitiesByMonth({required this.year, required this.month});
}

class FetchActivitiesByDay extends ActivitiesEvent {
  final String dateIso; // YYYY-MM-DD
  final bool showLoading;

  FetchActivitiesByDay({required this.dateIso, this.showLoading = true});
}

class CreateActivityEvent extends ActivitiesEvent {
  final CreateActivityRequestModel request;
  final String? correlationId;

  CreateActivityEvent({required this.request, this.correlationId});
}

class UpdateActivityEvent extends ActivitiesEvent {
  final String id;
  final CreateActivityRequestModel request;

  UpdateActivityEvent({required this.id, required this.request});
}

class DeleteActivityEvent extends ActivitiesEvent {
  final String id;
  final String? correlationId;

  DeleteActivityEvent({required this.id, this.correlationId});
}