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
