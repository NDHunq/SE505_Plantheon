import '../../entities/financial_entities.dart';
import '../../repository/activities_repository.dart';

class GetAnnualFinancial {
  final ActivitiesRepository repository;

  GetAnnualFinancial(this.repository);

  Future<AnnualFinancialEntity> call({required int year}) async {
    return await repository.getAnnualFinancial(year: year);
  }
}
