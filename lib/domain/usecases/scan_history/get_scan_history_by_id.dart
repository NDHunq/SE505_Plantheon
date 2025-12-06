import 'package:se501_plantheon/domain/entities/scan_history.dart';
import 'package:se501_plantheon/domain/repository/scan_history_repository.dart';

class GetScanHistoryById {
  final ScanHistoryRepository repository;

  GetScanHistoryById({required this.repository});

  Future<ScanHistoryEntity> call(String id) async {
    final entity = await repository.getScanHistoryById(id);
    return entity;
  }
}
