import 'dart:io';

abstract class ScanHistoryEvent {}

class GetAllScanHistoryEvent extends ScanHistoryEvent {
  final int? size;

  GetAllScanHistoryEvent({this.size});
}

class CreateScanHistoryEvent extends ScanHistoryEvent {
  final String diseaseId;
  final File? scanImage;

  CreateScanHistoryEvent({
    required this.diseaseId,
    this.scanImage,
  });
}
