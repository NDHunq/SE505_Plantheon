import 'package:se501_plantheon/domain/entities/scan_history.dart';

abstract class ScanHistoryRepository {
  Future<List<ScanHistoryEntity>> getAllScanHistory();
}
