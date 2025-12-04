import 'package:se501_plantheon/domain/entities/scan_history.dart';

abstract class ScanHistoryRepository {
  Future<List<ScanHistoryEntity>> getAllScanHistory({int? size});
  Future<ScanHistoryEntity> createScanHistory(String diseaseId, {String? scanImage});
}
