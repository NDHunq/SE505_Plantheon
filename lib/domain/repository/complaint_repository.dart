import 'package:se501_plantheon/domain/entities/complaint_entity.dart';
import 'package:se501_plantheon/domain/entities/complaint_history_entity.dart';

abstract class ComplaintRepository {
  Future<void> submitComplaint(ComplaintEntity complaint);
  Future<List<ComplaintHistoryEntity>> getComplaintsAboutMe({
    int page,
    int limit,
  });
}
