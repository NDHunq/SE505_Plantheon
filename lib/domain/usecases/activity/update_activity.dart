import 'package:se501_plantheon/domain/repository/activities_repository.dart';
import 'package:se501_plantheon/data/models/activities_models.dart';

class UpdateActivity {
  final ActivitiesRepository repository;

  UpdateActivity(this.repository);

  Future<CreateActivityResponseModel> call({
    required String id,
    required CreateActivityRequestModel request,
  }) async {
    return await repository.updateActivity(id: id, request: request);
  }
}
