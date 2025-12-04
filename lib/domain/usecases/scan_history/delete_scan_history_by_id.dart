import 'package:se501_plantheon/domain/repository/scan_history_repository.dart';

class DeleteScanHistoryById {
  final ScanHistoryRepository repository;

  DeleteScanHistoryById({required this.repository});

  Future<void> call(String id) async {
    await repository.deleteScanHistoryById(id);
  }
}
