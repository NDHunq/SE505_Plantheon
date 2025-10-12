import 'package:se501_plantheon/data/models/activities_models.dart';
import 'package:se501_plantheon/domain/entities/activities_entities.dart';

abstract class ActivitiesState {}

class ActivitiesInitial extends ActivitiesState {}

class ActivitiesLoading extends ActivitiesState {}

class ActivitiesLoaded extends ActivitiesState {
  final MonthActivitiesModel data;
  ActivitiesLoaded({required this.data});
}

class ActivitiesError extends ActivitiesState {
  final String message;
  ActivitiesError({required this.message});
}

class DayActivitiesLoading extends ActivitiesState {}

class DayActivitiesLoaded extends ActivitiesState {
  final DayActivitiesOfDayEntity data;
  DayActivitiesLoaded({required this.data});
}

class CreateActivityLoading extends ActivitiesState {}

class CreateActivitySuccess extends ActivitiesState {
  final CreateActivityResponseModel response;
  CreateActivitySuccess({required this.response});
}

class CreateActivityError extends ActivitiesState {
  final String message;
  CreateActivityError({required this.message});
}

class UpdateActivityLoading extends ActivitiesState {}

class UpdateActivitySuccess extends ActivitiesState {
  final CreateActivityResponseModel response;
  UpdateActivitySuccess({required this.response});
}

class UpdateActivityError extends ActivitiesState {
  final String message;
  UpdateActivityError({required this.message});
}
