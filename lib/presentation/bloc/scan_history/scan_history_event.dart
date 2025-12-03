abstract class ScanHistoryEvent {}

class GetAllScanHistoryEvent extends ScanHistoryEvent {}

class CreateScanHistoryEvent extends ScanHistoryEvent {
  final String diseaseId;

  CreateScanHistoryEvent({required this.diseaseId});
}
