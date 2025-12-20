import 'package:se501_plantheon/domain/entities/keyword_activity_entity.dart';

abstract class KeywordActivitiesState {}

class KeywordActivitiesInitial extends KeywordActivitiesState {}

class KeywordActivitiesLoading extends KeywordActivitiesState {}

class KeywordActivitiesLoaded extends KeywordActivitiesState {
  final List<KeywordActivityEntity> activities;

  KeywordActivitiesLoaded({required this.activities});
}

class KeywordActivitiesError extends KeywordActivitiesState {
  final String message;

  KeywordActivitiesError({required this.message});
}