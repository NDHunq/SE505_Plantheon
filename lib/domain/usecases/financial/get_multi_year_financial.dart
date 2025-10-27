import '../../entities/financial_entities.dart';
import '../../repository/activities_repository.dart';

class GetMultiYearFinancial {
  final ActivitiesRepository repository;

  GetMultiYearFinancial(this.repository);

  Future<MultiYearFinancialEntity> call({
    required int startYear,
    required int endYear,
  }) async {
    return await repository.getMultiYearFinancial(
      startYear: startYear,
      endYear: endYear,
    );
  }
}
