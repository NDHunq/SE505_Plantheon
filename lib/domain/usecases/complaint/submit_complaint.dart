import 'package:se501_plantheon/domain/entities/complaint_entity.dart';
import 'package:se501_plantheon/domain/repository/complaint_repository.dart';

class SubmitComplaint {
  final ComplaintRepository repository;

  SubmitComplaint(this.repository);

  Future<void> call(ComplaintEntity complaint) async {
    return await repository.submitComplaint(complaint);
  }
}
