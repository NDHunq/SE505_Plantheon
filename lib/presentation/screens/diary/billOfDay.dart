import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/presentation/screens/diary/widgets/task.dart';
import 'package:se501_plantheon/presentation/screens/diary/billOfMonth.dart';
import 'package:se501_plantheon/data/datasources/activities_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/activities_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/financial/get_monthly_financial.dart';
import 'package:se501_plantheon/domain/usecases/financial/get_annual_financial.dart';
import 'package:se501_plantheon/domain/usecases/financial/get_multi_year_financial.dart';
import 'package:se501_plantheon/presentation/bloc/financial/financial_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/financial/financial_event.dart';
import 'package:se501_plantheon/presentation/bloc/financial/financial_state.dart';
import 'package:se501_plantheon/domain/entities/financial_entities.dart';

class BillOfDay extends StatefulWidget {
  final DateTime? initialDate;
  final Function(String)? onTitleChange;
  final Function()? onBackToCalendar;
  final Function(DateTime)? onNavigateToBillOfMonth;

  const BillOfDay({
    super.key,
    this.initialDate,
    this.onTitleChange,
    this.onBackToCalendar,
    this.onNavigateToBillOfMonth,
  });

  @override
  State<BillOfDay> createState() => _BillOfDayState();
}

class _BillOfDayState extends State<BillOfDay> {
  late DateTime currentMonth;
  late int expandedDay;
  late ScrollController scrollController;
  final Map<int, GlobalKey> dayKeys = {};
  late FinancialBloc _financialBloc;

  @override
  void initState() {
    super.initState();
    currentMonth = widget.initialDate ?? DateTime.now();
    expandedDay = widget.initialDate?.day ?? 1;
    scrollController = ScrollController();

    // Initialize keys for all days
    for (int i = 1; i <= 31; i++) {
      dayKeys[i] = GlobalKey();
    }

    // Initialize Financial BLoC
    final repository = ActivitiesRepositoryImpl(
      remoteDataSource: ActivitiesRemoteDataSourceImpl(client: http.Client()),
    );
    _financialBloc = FinancialBloc(
      getMonthlyFinancial: GetMonthlyFinancial(repository),
      getAnnualFinancial: GetAnnualFinancial(repository),
      getMultiYearFinancial: GetMultiYearFinancial(repository),
    );

    // Fetch data
    _fetchMonthlyData();

    // Auto scroll to selected day after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDay(expandedDay);

      // Cập nhật title
      if (widget.onTitleChange != null) {
        widget.onTitleChange!('Báo cáo ngày');
      }
    });
  }

  void _fetchMonthlyData() {
    _financialBloc.add(
      FetchMonthlyFinancial(year: currentMonth.year, month: currentMonth.month),
    );
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
        if (state is MonthlyFinancialLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FinancialError) {
          return Center(child: Text('Lỗi: ${state.message}'));
        } else if (state is MonthlyFinancialLoaded) {
          return _buildContent(state.data);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildContent(MonthlyFinancialEntity data) {
    // Group activities by day
    final Map<int, List<FinancialActivityEntity>> dailyActivities = {};
    for (var activity in data.activities) {
      final day = activity.timeStart.toLocal().day;
      if (!dailyActivities.containsKey(day)) {
        dailyActivities[day] = [];
      }
      dailyActivities[day]!.add(activity);
    }

    return Column(
      children: [
        // Tổng kết tháng
        _buildMonthSummary(data),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),

        // Danh sách ngày
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
            child: Column(
              children: [
                // Danh sách ngày
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _getDaysInMonth(),
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final isExpanded = day == expandedDay;
                      final activities = dailyActivities[day] ?? [];
                      final dayBalance = _calculateDayBalance(activities);

                      return _buildDayItem(
                        day: day,
                        balance: dayBalance,
                        activities: activities,
                        isExpanded: isExpanded,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSummary(MonthlyFinancialEntity data) {
    final monthIncome = data.totalIncome.abs();
    final monthExpense = data.totalExpense.abs();
    final monthBalance = data.netAmount;

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
          // Tháng hiện tại
          Row(
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.primary_600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (widget.onNavigateToBillOfMonth != null) {
                    widget.onNavigateToBillOfMonth!(currentMonth);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BillOfMonth(initialDate: currentMonth),
                      ),
                    );
                  }
                },
                child: Text(
                  "Thg ${currentMonth.month}, ${currentMonth.year}",
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.primary_600,
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary_600,
                ),
              ),
            ],
          ),

          // Tổng kết
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "+${monthIncome.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primary_600,
                ),
              ),
              Text(
                "-${monthExpense.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              Text(
                "= ${monthBalance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem({
    required int day,
    required double balance,
    required List<FinancialActivityEntity> activities,
    required bool isExpanded,
  }) {
    return Column(
      children: [
        // Header ngày
        InkWell(
          onTap: () => _toggleDay(day),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstraints.mainPadding,
              vertical: AppConstraints.smallPadding,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    day.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 24,
                      color: _isToday(day)
                          ? AppColors.primary_600
                          : _isFutureDay(day)
                          ? Colors.grey
                          : AppColors.text_color_900,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    balance == 0
                        ? "0 đ"
                        : "${balance > 0 ? '+' : ''}${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                    style: TextStyle(
                      fontSize: AppConstraints.normalTextFontSize,
                      color: balance > 0
                          ? AppColors.primary_600
                          : balance < 0
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),

        // Chi tiết giao dịch
        if (isExpanded && activities.isNotEmpty)
          ...activities.map(
            (activity) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstraints.mainPadding,
                vertical: AppConstraints.smallPadding / 2,
              ),
              child: _buildActivityWidget(activity),
            ),
          ),

        // Divider
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  Widget _buildActivityWidget(FinancialActivityEntity activity) {
    final startLocal = activity.timeStart.toLocal();
    final endLocal = activity.timeEnd.toLocal();

    final String startTime =
        '${startLocal.day.toString().padLeft(2, '0')}/'
        '${startLocal.month.toString().padLeft(2, '0')} '
        '${startLocal.hour.toString().padLeft(2, '0')}:'
        '${startLocal.minute.toString().padLeft(2, '0')}';

    final String endTime =
        '${endLocal.day.toString().padLeft(2, '0')}/'
        '${endLocal.month.toString().padLeft(2, '0')} '
        '${endLocal.hour.toString().padLeft(2, '0')}:'
        '${endLocal.minute.toString().padLeft(2, '0')}';

    final String amountText = activity.money != null
        ? "${activity.money! > 0 ? '+' : ''}${activity.money!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ"
        : "0 đ";

    // Determine color based on type
    Color baseColor;
    switch (activity.type.toUpperCase()) {
      case 'EXPENSE':
        baseColor = Colors.red;
        break;
      case 'INCOME':
      case 'PRODUCT':
        baseColor = Colors.green;
        break;
      case 'DISEASE':
        baseColor = Colors.orange;
        break;
      case 'TECHNIQUE':
        baseColor = Colors.blue;
        break;
      case 'CLIMATE':
        baseColor = Colors.purple;
        break;
      case 'OTHER':
        baseColor = Colors.grey;
        break;
      default:
        baseColor = Colors.blue;
    }

    return SizedBox(
      width: double.infinity,
      child: TaskWidget(
        title: activity.title,
        amountText: amountText,
        startTime: startTime,
        endTime: endTime,
        baseColor: baseColor,
        isShort: false,
      ),
    );
  }

  void _toggleDay(int day) {
    setState(() {
      expandedDay = expandedDay == day ? -1 : day;
    });
  }

  void _previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
      _fetchMonthlyData();
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      _fetchMonthlyData();
    });
  }

  int _getDaysInMonth() {
    return DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
  }

  double _calculateDayBalance(List<FinancialActivityEntity> activities) {
    return activities.fold(0.0, (sum, activity) => sum + (activity.money ?? 0));
  }

  bool _isToday(int day) {
    final today = DateTime.now();
    return today.year == currentMonth.year &&
        today.month == currentMonth.month &&
        today.day == day;
  }

  bool _isFutureDay(int day) {
    final today = DateTime.now();
    final currentDate = DateTime(currentMonth.year, currentMonth.month, day);
    return currentDate.isAfter(today);
  }

  void _scrollToDay(int targetDay) {
    if (scrollController.hasClients) {
      // Tính toán chính xác hơn dựa trên số ngày và chiều cao thực tế
      final double itemHeight = 35.0; // Chiều cao cơ bản của mỗi ngày
      final double expandedItemHeight = 200.0; // Chiều cao khi expand

      double totalOffset = 0.0;

      // Tính offset dựa trên các ngày trước đó
      for (int day = 1; day < targetDay; day++) {
        if (day == expandedDay && day != targetDay) {
          totalOffset += expandedItemHeight;
        } else {
          totalOffset += itemHeight;
        }
      }

      // Scroll với offset chính xác hơn
      scrollController.animateTo(
        totalOffset,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }
}
