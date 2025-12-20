import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/financial/get_monthly_financial.dart';
import 'package:se501_plantheon/domain/usecases/financial/get_annual_financial.dart';
import 'package:se501_plantheon/domain/usecases/financial/get_multi_year_financial.dart';
import 'package:se501_plantheon/presentation/bloc/financial/financial_event.dart';
import 'package:se501_plantheon/presentation/bloc/financial/financial_state.dart';

class FinancialBloc extends Bloc<FinancialEvent, FinancialState> {
  final GetMonthlyFinancial getMonthlyFinancial;
  final GetAnnualFinancial getAnnualFinancial;
  final GetMultiYearFinancial getMultiYearFinancial;

  FinancialBloc({
    required this.getMonthlyFinancial,
    required this.getAnnualFinancial,
    required this.getMultiYearFinancial,
  }) : super(FinancialInitial()) {
    on<FetchMonthlyFinancial>(_onFetchMonthlyFinancial);
    on<FetchAnnualFinancial>(_onFetchAnnualFinancial);
    on<FetchMultiYearFinancial>(_onFetchMultiYearFinancial);
  }

  Future<void> _onFetchMonthlyFinancial(
    FetchMonthlyFinancial event,
    Emitter<FinancialState> emit,
  ) async {
    emit(MonthlyFinancialLoading());
    try {
      print(
        '[FinancialBloc] Fetching monthly financial: year=${event.year}, month=${event.month}',
      );
      final entity = await getMonthlyFinancial(
        year: event.year,
        month: event.month,
      );
      print(
        '[FinancialBloc] Monthly financial loaded: totalIncome=${entity.totalIncome}, totalExpense=${entity.totalExpense}, activities count=${entity.activities.length}',
      );
      emit(MonthlyFinancialLoaded(data: entity));
    } catch (e) {
      print('[FinancialBloc] Error: $e');
      emit(FinancialError(message: e.toString()));
    }
  }

  Future<void> _onFetchAnnualFinancial(
    FetchAnnualFinancial event,
    Emitter<FinancialState> emit,
  ) async {
    emit(AnnualFinancialLoading());
    try {
      print('[FinancialBloc] Fetching annual financial: year=${event.year}');
      final entity = await getAnnualFinancial(year: event.year);
      print(
        '[FinancialBloc] Annual financial loaded: totalIncome=${entity.totalIncome}, totalExpense=${entity.totalExpense}, months count=${entity.monthlySummaries.length}',
      );
      emit(AnnualFinancialLoaded(data: entity));
    } catch (e) {
      print('[FinancialBloc] Error: $e');
      emit(FinancialError(message: e.toString()));
    }
  }

  Future<void> _onFetchMultiYearFinancial(
    FetchMultiYearFinancial event,
    Emitter<FinancialState> emit,
  ) async {
    emit(MultiYearFinancialLoading());
    try {
      print(
        '[FinancialBloc] Fetching multi-year financial: startYear=${event.startYear}, endYear=${event.endYear}',
      );
      final entity = await getMultiYearFinancial(
        startYear: event.startYear,
        endYear: event.endYear,
      );
      print(
        '[FinancialBloc] Multi-year financial loaded: totalIncome=${entity.totalIncome}, totalExpense=${entity.totalExpense}, years count=${entity.yearlySummaries.length}',
      );
      emit(MultiYearFinancialLoaded(data: entity));
    } catch (e) {
      print('[FinancialBloc] Error: $e');
      emit(FinancialError(message: e.toString()));
    }
  }
}