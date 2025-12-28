import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
import 'package:se501_plantheon/presentation/screens/diary/bill_of_year.dart';
import 'package:se501_plantheon/presentation/screens/diary/bill_of_day.dart';
import 'package:se501_plantheon/common/helpers/money_formatter.dart';

class BillOfMonth extends StatefulWidget {
  final DateTime? initialDate;
  final Function(String)? onTitleChange;
  final Function()? onBackToCalendar;
  final Function(DateTime)? onNavigateToBillOfYear;
  final Function(DateTime)? onNavigateToBillOfDay;

  const BillOfMonth({
    super.key,
    this.initialDate,
    this.onTitleChange,
    this.onBackToCalendar,
    this.onNavigateToBillOfYear,
    this.onNavigateToBillOfDay,
  });

  @override
  State<BillOfMonth> createState() => _BillOfMonthState();
}

class _BillOfMonthState extends State<BillOfMonth> {
  late DateTime currentYear;
  late ScrollController scrollController;
  late FinancialBloc _financialBloc;

  @override
  void initState() {
    super.initState();
    currentYear = widget.initialDate ?? DateTime.now();
    scrollController = ScrollController();

    // Initialize Financial BLoC
    final repository = ActivitiesRepositoryImpl(
      remoteDataSource: ActivitiesRemoteDataSourceImpl(client: http.Client()),
    );
    _financialBloc = FinancialBloc(
      getMonthlyFinancial: GetMonthlyFinancial(repository),
      getAnnualFinancial: GetAnnualFinancial(repository),
      getMultiYearFinancial: GetMultiYearFinancial(repository),
    );

    // Fetch annual data
    _fetchAnnualData();

    // Auto scroll to selected month after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetMonth = widget.initialDate?.month ?? DateTime.now().month;
      _scrollToMonth(targetMonth);

      // Cập nhật title
      if (widget.onTitleChange != null) {
        widget.onTitleChange!('Báo cáo tháng');
      }
    });
  }

  void _fetchAnnualData() {
    _financialBloc.add(FetchAnnualFinancial(year: currentYear.year));
  }

  @override
  void dispose() {
    scrollController.dispose();
    _financialBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinancialBloc, FinancialState>(
      bloc: _financialBloc,
      builder: (context, state) {
        if (state is AnnualFinancialLoading) {
          return const Center(child: LoadingIndicator());
        }

        if (state is FinancialError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                SizedBox(height: 16.sp),
                Text('Lỗi: ${state.message}'),
                SizedBox(height: 16.sp),
                ElevatedButton(
                  onPressed: _fetchAnnualData,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state is AnnualFinancialLoaded) {
          return _buildContent(state.data.monthlySummaries);
        }

        return const Center(child: Text('Không có dữ liệu'));
      },
    );
  }

  Widget _buildContent(List<dynamic> monthlySummaries) {
    // Convert to map for easier access
    final Map<int, dynamic> summaryMap = {};
    for (var summary in monthlySummaries) {
      summaryMap[summary.month] = summary;
    }

    return Column(
      children: [
        // Tổng kết năm
        _buildYearSummary(summaryMap),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.sp),
          child: Divider(),
        ),

        // Danh sách tháng
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: AppConstraints.mainPadding.sp,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                AppConstraints.mediumBorderRadius.sp,
              ),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                // Danh sách 12 tháng
                for (int month = 1; month <= 12; month++)
                  _buildMonthItem(month, summaryMap),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearSummary(Map<int, dynamic> summaryMap) {
    // Tính tổng thu nhập và chi tiêu của năm
    double yearIncome = 0;
    double yearExpense = 0;

    summaryMap.forEach((month, summary) {
      yearIncome += summary.totalIncome;
      yearExpense += summary.totalExpense.abs();
    });

    double yearBalance = yearIncome - yearExpense;

    return Container(
      padding: EdgeInsets.only(right: 24.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AppConstraints.mediumBorderRadius.sp,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Năm hiện tại
          Expanded(
            child: Row(
              children: [
                IconButton(
                  onPressed: _previousYear,
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.primary_600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.onNavigateToBillOfYear != null) {
                      widget.onNavigateToBillOfYear!(currentYear);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BillOfYear(initialDate: currentYear),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Năm ${currentYear.year}",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.primary_600,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                IconButton(
                  onPressed: _nextYear,
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary_600,
                  ),
                ),
              ],
            ),
          ),

          // Tổng kết năm
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "+${MoneyFormatter.format(yearIncome)} ₫",
                style: TextStyle(fontSize: 13.sp, color: AppColors.primary_600),
              ),
              Text(
                "-${MoneyFormatter.format(yearExpense)} ₫",
                style: TextStyle(color: Colors.red, fontSize: 13.sp),
              ),
              Text(
                "= ${MoneyFormatter.format(yearBalance)} ₫",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthItem(int month, Map<int, dynamic> summaryMap) {
    final summary = summaryMap[month];
    final double income = summary?.totalIncome ?? 0;
    final double expense = (summary?.totalExpense ?? 0).abs();
    final double balance = income - expense;
    final String monthName = _getMonthName(month);

    return Column(
      children: [
        InkWell(
          onTap: () {
            if (widget.onNavigateToBillOfDay != null) {
              widget.onNavigateToBillOfDay!(
                DateTime(currentYear.year, month, 1),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BillOfDay(
                    initialDate: DateTime(currentYear.year, month, 1),
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstraints.mainPadding.sp,
              vertical: AppConstraints.largePadding.sp,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    monthName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: _isCurrentMonth(month)
                          ? AppColors.primary_600
                          : AppColors.text_color_900,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "+${MoneyFormatter.format(income)} ₫",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary_600,
                        ),
                      ),
                      Text(
                        "-${MoneyFormatter.format(expense)} ₫",
                        style: TextStyle(fontSize: 12.sp, color: Colors.red),
                      ),
                      Text(
                        "= ${MoneyFormatter.format(balance)} ₫",
                        style: TextStyle(
                          fontSize: AppConstraints.normalTextFontSize.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Divider
        Divider(height: 1.sp, color: Colors.grey),
      ],
    );
  }

  void _previousYear() {
    setState(() {
      currentYear = DateTime(
        currentYear.year - 1,
        currentYear.month,
        currentYear.day,
      );
    });
    _fetchAnnualData();
  }

  void _nextYear() {
    setState(() {
      currentYear = DateTime(
        currentYear.year + 1,
        currentYear.month,
        currentYear.day,
      );
    });
    _fetchAnnualData();
  }

  bool _isCurrentMonth(int month) {
    final now = DateTime.now();
    return currentYear.year == now.year && month == now.month;
  }

  String _getMonthName(int month) {
    const monthNames = [
      '', // 0 không dùng
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ];
    return monthNames[month];
  }

  void _scrollToMonth(int targetMonth) {
    if (scrollController.hasClients) {
      // Tính toán offset dựa trên vị trí tháng
      final double itemHeight = 50.0; // Chiều cao cơ bản của mỗi tháng
      final double targetOffset = (targetMonth - 1) * itemHeight;

      scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }
}
