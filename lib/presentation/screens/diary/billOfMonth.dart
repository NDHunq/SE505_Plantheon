import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/data/datasources/activities_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/activities_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/get_monthly_financial.dart';
import 'package:se501_plantheon/domain/usecases/get_annual_financial.dart';
import 'package:se501_plantheon/domain/usecases/get_multi_year_financial.dart';
import 'package:se501_plantheon/presentation/bloc/financial/financial_bloc.dart';

import 'package:se501_plantheon/presentation/bloc/financial/financial_event.dart';
import 'package:se501_plantheon/presentation/bloc/financial/financial_state.dart';
import 'package:se501_plantheon/presentation/screens/diary/billOfYear.dart';
import 'package:se501_plantheon/presentation/screens/diary/billOfDay.dart';

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
          return const Center(child: CircularProgressIndicator());
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),

        // Danh sách tháng
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
      padding: const EdgeInsets.only(right: AppConstraints.largePadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Năm hiện tại
          Row(
            children: [
              IconButton(
                onPressed: _previousYear,
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.primary_600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  final now = DateTime.now();
                  // Kiểm tra nếu là năm tương lai
                  if (currentYear.year > now.year) {
                    _showFutureWarning();
                    return;
                  }

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
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.primary_600,
                  ),
                ),
              ),
              if (!_isCurrentYear())
                IconButton(
                  onPressed: _nextYear,
                  icon: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary_600,
                  ),
                ),
            ],
          ),

          // Tổng kết năm
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "+${yearIncome.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primary_600,
                ),
              ),
              Text(
                "-${yearExpense.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              Text(
                "= ${yearBalance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(color: Colors.black, fontSize: 16),
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstraints.mainPadding,
              vertical: AppConstraints.largePadding,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    monthName,
                    style: TextStyle(
                      fontSize: 24,
                      color: _isCurrentMonth(month)
                          ? AppColors.primary_600
                          : _isFutureMonth(month)
                          ? Colors.grey
                          : AppColors.text_color_900,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "+${income.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary_600,
                        ),
                      ),
                      Text(
                        "-${expense.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                      Text(
                        "= ${balance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                        style: const TextStyle(
                          fontSize: AppConstraints.normalTextFontSize,
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
        const Divider(height: 1, color: Colors.grey),
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
    final now = DateTime.now();
    // Chỉ cho phép chuyển tiếp nếu chưa đến năm hiện tại
    if (currentYear.year < now.year) {
      setState(() {
        currentYear = DateTime(
          currentYear.year + 1,
          currentYear.month,
          currentYear.day,
        );
      });
      _fetchAnnualData();
    }
  }

  bool _isCurrentYear() {
    final now = DateTime.now();
    return currentYear.year == now.year;
  }

  bool _isCurrentMonth(int month) {
    final now = DateTime.now();
    return currentYear.year == now.year && month == now.month;
  }

  bool _isFutureMonth(int month) {
    final now = DateTime.now();
    final monthDate = DateTime(currentYear.year, month, 1);
    return monthDate.isAfter(DateTime(now.year, now.month, 1));
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

  void _showFutureWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Thông báo",
          style: TextStyle(
            color: AppColors.primary_600,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Không có thống kê trong tương lai",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Đóng",
              style: TextStyle(color: AppColors.primary_600),
            ),
          ),
        ],
      ),
    );
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
