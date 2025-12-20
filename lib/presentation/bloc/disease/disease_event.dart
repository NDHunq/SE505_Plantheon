abstract class DiseaseEvent {}

class GetDiseaseEvent extends DiseaseEvent {
  final String diseaseId;

  GetDiseaseEvent({required this.diseaseId});
}