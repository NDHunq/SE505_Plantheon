import 'package:se501_plantheon/data/models/activities_models.dart';
import 'package:se501_plantheon/domain/repository/activities_repository.dart';

class CreateActivity {
  final ActivitiesRepository repository;

  CreateActivity(this.repository);

  Future<CreateActivityResponseModel> call({
    required CreateActivityRequestModel request,
  }) async {
    print('[CreateActivity] Creating activity with title=${request.title}');
    return await repository.createActivity(request: request);
  }
}
