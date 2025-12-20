import 'package:se501_plantheon/data/datasources/complaint_remote_datasource.dart';
import 'package:se501_plantheon/data/models/complaint_model.dart';
import 'package:se501_plantheon/domain/entities/complaint_entity.dart';
import 'package:se501_plantheon/domain/entities/complaint_history_entity.dart';
import 'package:se501_plantheon/domain/repository/complaint_repository.dart';

class ComplaintRepositoryImpl implements ComplaintRepository {
  final ComplaintRemoteDataSource remoteDataSource;

  ComplaintRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> submitComplaint(ComplaintEntity complaint) async {
    final model = ComplaintModel.fromEntity(complaint);
    await remoteDataSource.submitComplaint(model);
  }

  @override
  Future<List<ComplaintHistoryEntity>> getComplaintsAboutMe({
    int page = 1,
    int limit = 10,
  }) async {
    return await remoteDataSource.getComplaintsAboutMe(
      page: page,
      limit: limit,
    );
  }
}
