import 'package:se501_plantheon/domain/entities/scan_history.dart';

abstract class ScanHistoryRepository {
  Future<List<ScanHistoryEntity>> getAllScanHistory();
  Future<ScanHistoryEntity> createScanHistory(String diseaseId, {String? scanImage});
}
