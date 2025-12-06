import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/data/datasources/activities_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/activities_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/financial/get_monthly_financial.dart';
import 'package:se501_plantheon/domain/usecases/financial/get_annual_financial.dart';
import 'package:se501_plantheon/domain/usecases/financial/get_multi_year_financial.dart';
import 'package:se501_plantheon/presentation/bloc/financial/financial_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/financial/financial_event.dart';
import 'package:se501_plantheon/presentation/bloc/financial/financial_state.dart';
import 'package:se501_plantheon/presentation/screens/diary/billOfMonth.dart';

class BillOfYear extends StatefulWidget {
  final DateTime? initialDate;
  final Function(String)? onTitleChange;
  final Function()? onBackToCalendar;
  final Function(DateTime)? onNavigateToBillOfMonth;

  const BillOfYear({
    super.key,
    this.initialDate,
    this.onTitleChange,
    this.onBackToCalendar,
    this.onNavigateToBillOfMonth,
  });

  @override
  State<BillOfYear> createState() => _BillOfYearState();
}

class _BillOfYearState extends State<BillOfYear> {
  late DateTime currentDecade;
  late FinancialBloc _financialBloc;

  @override
  void initState() {
    super.initState();
    currentDecade = widget.initialDate ?? DateTime.now();

    // Initialize Financial BLoC
    final repository = ActivitiesRepositoryImpl(
      remoteDataSource: ActivitiesRemoteDataSourceImpl(client: http.Client()),
    );
    _financialBloc = FinancialBloc(
      getMonthlyFinancial: GetMonthlyFinancial(repository),
      getAnnualFinancial: GetAnnualFinancial(repository),
      getMultiYearFinancial: GetMultiYearFinancial(repository),
    );

    // Fetch multi-year data
    _fetchMultiYearData();

    // Cập nhật title
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onTitleChange != null) {
        widget.onTitleChange!('Báo cáo năm');
      }
    });
  }

  void _fetchMultiYearData() {
    final years = _getDecadeYears();
    if (years.isNotEmpty) {
      _financialBloc.add(
        FetchMultiYearFinancial(startYear: years.first, endYear: years.last),
      );
    }
  }

  @override
  void dispose() {
    _financialBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinancialBloc, FinancialState>(
      bloc: _financialBloc,
      builder: (context, state) {
        if (state is MultiYearFinancialLoading) {
          return const Center(child: LoadingIndicator());
        }

        if (state is FinancialError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Lỗi: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchMultiYearData,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state is MultiYearFinancialLoaded) {
          return _buildContent(state.data.yearlySummaries);
        }

        return const Center(child: Text('Không có dữ liệu'));
      },
    );
  }

  Widget _buildContent(List<dynamic> yearlySummaries) {
    // Convert to map for easier access
    final Map<int, dynamic> summaryMap = {};
    for (var summary in yearlySummaries) {
      summaryMap[summary.year] = summary;
    }

    return Column(
      children: [
        // Tổng kết thập kỷ
        _buildDecadeSummary(summaryMap),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),

        // Danh sách năm
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstraints.mainPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                AppConstraints.mediumBorderRadius,
              ),
            ),
            child: ListView(
              children: [
                // Danh sách các năm trong thập kỷ
                for (int year in _getDecadeYears())
                  _buildYearItem(year, summaryMap),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecadeSummary(Map<int, dynamic> summaryMap) {
    // Tính tổng thu nhập và chi tiêu của thập kỷ
    double decadeIncome = 0;
    double decadeExpense = 0;

    for (int year in _getDecadeYears()) {
      final summary = summaryMap[year];
      if (summary != null) {
        decadeIncome += summary.totalIncome;
        decadeExpense += summary.totalExpense.abs();
      }
    }

    double decadeBalance = decadeIncome - decadeExpense;
    final startYear = _getDecadeStart();
    final endYear = startYear + 9;

    return Container(
      padding: const EdgeInsets.only(right: AppConstraints.largePadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thập kỷ hiện tại
          Row(
            children: [
              IconButton(
                onPressed: _previousDecade,
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.primary_600,
                ),
              ),
              Text(
                "$startYear - $endYear",
                style: const TextStyle(
                  fontSize: 24,
                  color: AppColors.primary_600,
                ),
              ),
              IconButton(
                onPressed: _nextDecade,
                icon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary_600,
                ),
              ),
            ],
          ),

          // Tổng kết thập kỷ
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "+${decadeIncome.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primary_600,
                ),
              ),
              Text(
                "-${decadeExpense.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              Text(
                "= ${decadeBalance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearItem(int year, Map<int, dynamic> summaryMap) {
    final summary = summaryMap[year];
    final double income = summary?.totalIncome ?? 0;
    final double expense = (summary?.totalExpense ?? 0).abs();
    final double balance = income - expense;

    return Column(
      children: [
        InkWell(
          onTap: () {
            if (widget.onNavigateToBillOfMonth != null) {
              widget.onNavigateToBillOfMonth!(DateTime(year, 1, 1));
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BillOfMonth(initialDate: DateTime(year, 1, 1)),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstraints.mainPadding,
              vertical: AppConstraints.largePadding,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Năm $year",
                    style: TextStyle(
                      fontSize: 24,
                      color: _isCurrentYear(year)
                          ? AppColors.primary_600
                          : AppColors.text_color_900,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    balance == 0
                        ? "0 đ"
                        : "${balance > 0 ? '+' : ''}${balance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: AppConstraints.normalTextFontSize,
                      color: balance > 0
                          ? AppColors.primary_600
                          : balance < 0
                          ? Colors.red
                          : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Divider
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  void _previousDecade() {
    setState(() {
      currentDecade = DateTime(
        currentDecade.year - 10,
        currentDecade.month,
        currentDecade.day,
      );
    });
    _fetchMultiYearData();
  }

  void _nextDecade() {
    setState(() {
      currentDecade = DateTime(
        currentDecade.year + 10,
        currentDecade.month,
        currentDecade.day,
      );
    });
    _fetchMultiYearData();
  }

  bool _isCurrentYear(int year) {
    final now = DateTime.now();
    return year == now.year;
  }

  int _getDecadeStart() {
    final targetDecadeStart = (currentDecade.year ~/ 10) * 10;
    return targetDecadeStart;
  }

  List<int> _getDecadeYears() {
    final startYear = _getDecadeStart();
    List<int> years = [];

    // Hiển thị đầy đủ 10 năm của thập kỷ
    for (int year = startYear; year < startYear + 10; year++) {
      years.add(year);
    }

    return years;
  }
}
