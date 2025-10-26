import 'package:se501_plantheon/domain/entities/financial_entities.dart';
import 'package:se501_plantheon/domain/repository/activities_repository.dart';

class GetMonthlyFinancial {
  final ActivitiesRepository repository;

  GetMonthlyFinancial(this.repository);

  Future<MonthlyFinancialEntity> call({
    required int year,
    required int month,
  }) async {
    return await repository.getMonthlyFinancial(year: year, month: month);
  }
}
