import 'package:se501_plantheon/domain/repository/activities_repository.dart';

class DeleteActivity {
  final ActivitiesRepository repository;

  DeleteActivity(this.repository);

  Future<void> call({required String id}) async {
    await repository.deleteActivity(id: id);
  }
}
