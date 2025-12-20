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

class CreateActivityLoading extends ActivitiesState {
  final String? correlationId;
  CreateActivityLoading({this.correlationId});
}

class CreateActivitySuccess extends ActivitiesState {
  final CreateActivityResponseModel response;
  final String? correlationId;
  CreateActivitySuccess({required this.response, this.correlationId});
}

class CreateActivityError extends ActivitiesState {
  final String message;
  final String? correlationId;
  CreateActivityError({required this.message, this.correlationId});
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

class DeleteActivityLoading extends ActivitiesState {
  final String? correlationId;
  DeleteActivityLoading({this.correlationId});
}

class DeleteActivitySuccess extends ActivitiesState {
  final String? correlationId;
  DeleteActivitySuccess({this.correlationId});
}

class DeleteActivityError extends ActivitiesState {
  final String message;
  final String? correlationId;
  DeleteActivityError({required this.message, this.correlationId});
}