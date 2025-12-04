import 'package:se501_plantheon/domain/entities/scan_history.dart';
import 'package:se501_plantheon/domain/repository/scan_history_repository.dart';

class CreateScanHistory {
  final ScanHistoryRepository repository;

  CreateScanHistory({required this.repository});

  Future<ScanHistoryEntity> call(String diseaseId, {String? scanImage}) async {
    final entity = await repository.createScanHistory(diseaseId, scanImage: scanImage);
    return entity;
  }
}
