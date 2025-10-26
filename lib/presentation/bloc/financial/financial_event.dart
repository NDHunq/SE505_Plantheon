abstract class FinancialEvent {}

class FetchMonthlyFinancial extends FinancialEvent {
  final int year;
  final int month;

  FetchMonthlyFinancial({required this.year, required this.month});
}

class FetchAnnualFinancial extends FinancialEvent {
  final int year;

  FetchAnnualFinancial({required this.year});
}

class FetchMultiYearFinancial extends FinancialEvent {
  final int startYear;
  final int endYear;

  FetchMultiYearFinancial({required this.startYear, required this.endYear});
}
