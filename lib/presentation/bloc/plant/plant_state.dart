import 'package:se501_plantheon/domain/entities/plant_entity.dart';

abstract class PlantState {}

class PlantInitial extends PlantState {}

class PlantLoading extends PlantState {}

class PlantLoaded extends PlantState {
  final List<PlantEntity> plants;

  PlantLoaded({required this.plants});
}

class PlantError extends PlantState {
  final String message;

  PlantError({required this.message});
}

