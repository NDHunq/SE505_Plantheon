import 'package:se501_plantheon/domain/entities/scan_history.dart';
import 'package:se501_plantheon/domain/repository/scan_history_repository.dart';

class GetAllScanHistory {
  final ScanHistoryRepository repository;

  GetAllScanHistory({required this.repository});

  Future<List<ScanHistoryEntity>> call({int? size}) async {
    final entities = await repository.getAllScanHistory(size: size);
    return entities;
  }
}
