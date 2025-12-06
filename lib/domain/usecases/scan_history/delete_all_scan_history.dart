import 'package:se501_plantheon/domain/repository/scan_history_repository.dart';

class DeleteAllScanHistory {
  final ScanHistoryRepository repository;

  DeleteAllScanHistory({required this.repository});

  Future<void> call() async {
    await repository.deleteAllScanHistory();
  }
}
