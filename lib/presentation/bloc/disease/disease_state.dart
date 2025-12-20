import 'package:se501_plantheon/data/models/diseases.model.dart';

abstract class DiseaseState {}

class DiseaseInitial extends DiseaseState {}

class DiseaseLoading extends DiseaseState {}

class DiseaseSuccess extends DiseaseState {
  final DiseaseModel disease;

  DiseaseSuccess({required this.disease});
}

class DiseaseError extends DiseaseState {
  final String message;

  DiseaseError({required this.message});
}