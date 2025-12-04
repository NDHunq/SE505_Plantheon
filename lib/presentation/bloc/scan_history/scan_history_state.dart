import 'package:se501_plantheon/domain/entities/scan_history.dart';

abstract class ScanHistoryState {}

class ScanHistoryInitial extends ScanHistoryState {}

class ScanHistoryLoading extends ScanHistoryState {}

class ScanHistorySuccess extends ScanHistoryState {
  final List<ScanHistoryEntity> scanHistories;

  ScanHistorySuccess({required this.scanHistories});
}

class ScanHistoryError extends ScanHistoryState {
  final String message;

  ScanHistoryError({required this.message});
}

class CreateScanHistorySuccess extends ScanHistoryState {
  final ScanHistoryEntity scanHistory;

  CreateScanHistorySuccess({required this.scanHistory});
}

class GetScanHistoryByIdSuccess extends ScanHistoryState {
  final ScanHistoryEntity scanHistory;

  GetScanHistoryByIdSuccess({required this.scanHistory});
}

class DeleteAllScanHistorySuccess extends ScanHistoryState {}

class DeleteScanHistoryByIdSuccess extends ScanHistoryState {}
