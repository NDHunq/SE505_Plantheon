import 'package:se501_plantheon/domain/entities/scan_history.dart';

abstract class ScanHistoryRepository {
  Future<List<ScanHistoryEntity>> getAllScanHistory({int? size});
  Future<ScanHistoryEntity> getScanHistoryById(String id);
  Future<ScanHistoryEntity> createScanHistory(String diseaseId, {String? scanImage});
  Future<void> deleteAllScanHistory();
  Future<void> deleteScanHistoryById(String id);
}
