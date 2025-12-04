import 'dart:io';

abstract class ScanHistoryEvent {}

class GetAllScanHistoryEvent extends ScanHistoryEvent {
  final int? size;

  GetAllScanHistoryEvent({this.size});
}

class GetScanHistoryByIdEvent extends ScanHistoryEvent {
  final String id;

  GetScanHistoryByIdEvent({required this.id});
}

class CreateScanHistoryEvent extends ScanHistoryEvent {
  final String diseaseId;
  final File? scanImage;

  CreateScanHistoryEvent({
    required this.diseaseId,
    this.scanImage,
  });
}

class DeleteAllScanHistoryEvent extends ScanHistoryEvent {}

class DeleteScanHistoryByIdEvent extends ScanHistoryEvent {
  final String id;

  DeleteScanHistoryByIdEvent({required this.id});
}
