import 'package:se501_plantheon/domain/entities/financial_entities.dart';

abstract class FinancialState {}

class FinancialInitial extends FinancialState {}

class MonthlyFinancialLoading extends FinancialState {}

class MonthlyFinancialLoaded extends FinancialState {
  final MonthlyFinancialEntity data;

  MonthlyFinancialLoaded({required this.data});
}

class AnnualFinancialLoading extends FinancialState {}

class AnnualFinancialLoaded extends FinancialState {
  final AnnualFinancialEntity data;

  AnnualFinancialLoaded({required this.data});
}

class MultiYearFinancialLoading extends FinancialState {}

class MultiYearFinancialLoaded extends FinancialState {
  final MultiYearFinancialEntity data;

  MultiYearFinancialLoaded({required this.data});
}

class FinancialError extends FinancialState {
  final String message;

  FinancialError({required this.message});
}
