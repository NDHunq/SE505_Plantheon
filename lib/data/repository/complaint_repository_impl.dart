import 'package:se501_plantheon/data/datasources/complaint_remote_datasource.dart';
import 'package:se501_plantheon/data/models/complaint_model.dart';
import 'package:se501_plantheon/domain/entities/complaint_entity.dart';
import 'package:se501_plantheon/domain/entities/complaint_history_entity.dart';
import 'package:se501_plantheon/domain/repository/complaint_repository.dart';

class ComplaintRepositoryImpl implements ComplaintRepository {
  final ComplaintRemoteDataSource remoteDataSource;

  ComplaintRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ComplaintEntity> submitScanComplaint({
    required String predictedDiseaseId,
    required double confidenceScore,
    required String category,
    required String imageUrl,
    String? userSuggestedDiseaseId,
    String? content,
  }) async {
    print('🏛️ Repository: Submitting scan complaint');
    final ScanComplaintModel model = await remoteDataSource.submitScanComplaint(
      predictedDiseaseId: predictedDiseaseId,
      confidenceScore: confidenceScore,
      category: category,
      imageUrl: imageUrl,
      userSuggestedDiseaseId: userSuggestedDiseaseId,
      content: content,
    );
    print('📦 Repository: Received complaint model with id: ${model.id}');

    final entity = _mapModelToEntity(model);
    print('🔄 Repository: Mapped to entity');
    return entity;
  }

  @override
  Future<void> submitComplaint(ComplaintEntity complaint) async {
    final model = ScanComplaintModel.fromEntity(complaint);
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

  ComplaintEntity _mapModelToEntity(ScanComplaintModel model) {
    return ComplaintEntity(
      id: model.id,
      userId: model.userId,
      targetId: model.targetId,
      targetType: model.targetType,
      category: model.category,
      content: model.content,
      imageUrl: model.imageUrl,
      status: model.status,
      predictedDiseaseId: model.predictedDiseaseId,
      userSuggestedDiseaseId: model.userSuggestedDiseaseId,
      confidenceScore: model.confidenceScore,
      isVerified: model.isVerified,
      verifiedDiseaseId: model.verifiedDiseaseId,
      verifiedBy: model.verifiedBy,
      verifiedAt: model.verifiedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
