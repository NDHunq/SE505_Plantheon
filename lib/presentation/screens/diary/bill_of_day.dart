import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/presentation/screens/diary/widgets/task.dart';
import 'package:se501_plantheon/presentation/screens/diary/bill_of_month.dart';
import 'package:se501_plantheon/common/helpers/money_formatter.dart';
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
          return const Center(child: LoadingIndicator());
        } else if (state is FinancialError) {
          return Center(child: Text('Lỗi: ${state.message}'));
        } else if (state is MonthlyFinancialLoaded) {
          return _buildContent(state.data);
        }
        return const Center(child: LoadingIndicator());
      },
    );
  }

  Widget _buildContent(MonthlyFinancialEntity data) {
    // Group activities by day, including recurring activity occurrences
    final int daysInMonth = _getDaysInMonth();
    final Map<int, List<FinancialActivityEntity>> dailyActivities = {};
    for (int d = 1; d <= daysInMonth; d++) {
      dailyActivities[d] = [];
    }

    for (var activity in data.activities) {
      // Normal (non-recurring) instances: add to its start day if within this month
      final localStart = activity.timeStart.toLocal();
      if (localStart.year == currentMonth.year &&
          localStart.month == currentMonth.month) {
        final day = localStart.day;
        dailyActivities[day]!.add(activity);
      }

      // If activity is recurring, generate occurrences within the current month
      final bool isRecurring =
          activity.repeat != null &&
          activity.repeat!.isNotEmpty &&
          activity.repeat != "Không";
      if (isRecurring) {
        for (int d = 1; d <= daysInMonth; d++) {
          final date = DateTime(currentMonth.year, currentMonth.month, d);
          // avoid duplicating the original instance if it falls on this date
          if (localStart.year == date.year &&
              localStart.month == date.month &&
              localStart.day == date.day)
            continue;
          if (_activityOccursOnDate(activity, date)) {
            // Create an adjusted copy for display (preserve time-of-day and duration)
            final occ = _activityInstanceForDate(activity, date);
            dailyActivities[d]!.add(occ);
          }
        }
      }
    }

    return Column(
      children: [
        // Tổng kết tháng
        _buildMonthSummary(data),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.sp),
          child: Divider(),
        ),

        // Danh sách ngày
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
          // Tháng hiện tại
          Expanded(
            child: Row(
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(
                    Icons.chevron_left_rounded,
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
                    "${currentMonth.month}/${currentMonth.year}",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.primary_600,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                IconButton(
                  onPressed: _nextMonth,
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary_600,
                  ),
                ),
              ],
            ),
          ),

          // Tổng kết
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "+${MoneyFormatter.format(monthIncome)} ₫",
                style: TextStyle(fontSize: 13.sp, color: AppColors.primary_600),
              ),
              Text(
                "-${MoneyFormatter.format(monthExpense)} ₫",
                style: TextStyle(color: Colors.red, fontSize: 13.sp),
              ),
              Text(
                "= ${MoneyFormatter.format(monthBalance)} ₫",
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
            padding: EdgeInsets.symmetric(
              horizontal: AppConstraints.mainPadding.sp,
              vertical: AppConstraints.smallPadding.sp,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    day.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
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
                        ? "0 ₫"
                        : "${balance > 0 ? '+' : ''}${MoneyFormatter.format(balance)} ₫",
                    style: TextStyle(
                      fontSize: AppConstraints.normalTextFontSize.sp,
                      color: balance > 0
                          ? AppColors.primary_600
                          : balance < 0
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
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
              padding: EdgeInsets.symmetric(
                horizontal: AppConstraints.mainPadding.sp,
                vertical: AppConstraints.smallPadding.sp / 2,
              ),
              child: _buildActivityWidget(activity),
            ),
          ),

        // Divider
        Divider(height: 1.sp, color: Colors.grey),
      ],
    );
  }

  Widget _buildActivityWidget(FinancialActivityEntity activity) {
    final startLocal = activity.timeStart.toLocal();
    final endLocal = activity.timeEnd.toLocal();

    // Check if recurring
    final bool isRecurring =
        activity.repeat != null &&
        activity.repeat!.isNotEmpty &&
        activity.repeat != "Không";

    String startTime;
    String endTime;

    if (activity.day) {
      // Cả ngày: không hiển thị giờ
      startTime =
          '${startLocal.day.toString().padLeft(2, '0')}/'
          '${startLocal.month.toString().padLeft(2, '0')}';
      endTime =
          '${endLocal.day.toString().padLeft(2, '0')}/'
          '${endLocal.month.toString().padLeft(2, '0')}';
    } else if (isRecurring) {
      // Activity lặp lại: hiển thị format giống dayDetail
      final String hourStart =
          '${startLocal.hour.toString().padLeft(2, '0')}:'
          '${startLocal.minute.toString().padLeft(2, '0')}';

      String repeatText = '';
      switch (activity.repeat) {
        case 'Hàng ngày':
          repeatText = 'hàng ngày';
          break;
        case 'Hàng tuần':
          final weekdays = [
            'CN',
            'Thứ 2',
            'Thứ 3',
            'Thứ 4',
            'Thứ 5',
            'Thứ 6',
            'Thứ 7',
          ];
          repeatText = '${weekdays[startLocal.weekday % 7]} hàng tuần:';
          break;
        case 'Hàng tháng':
          repeatText = 'Hàng tháng';
          break;
        case 'Hàng năm':
          repeatText = 'Hàng năm';
          break;
        default:
          repeatText = activity.repeat!.toLowerCase();
      }

      startTime = '$repeatText $hourStart ';
      endTime =
          '${endLocal.hour.toString().padLeft(2, '0')}:'
          '${endLocal.minute.toString().padLeft(2, '0')}';
    } else {
      // Activity thường: hiển thị đầy đủ ngày giờ
      startTime =
          '${startLocal.day.toString().padLeft(2, '0')}/'
          '${startLocal.month.toString().padLeft(2, '0')} '
          '${startLocal.hour.toString().padLeft(2, '0')}:'
          '${startLocal.minute.toString().padLeft(2, '0')}';
      endTime =
          '${endLocal.day.toString().padLeft(2, '0')}/'
          '${endLocal.month.toString().padLeft(2, '0')} '
          '${endLocal.hour.toString().padLeft(2, '0')}:'
          '${endLocal.minute.toString().padLeft(2, '0')}';
    }

    final String amountText = activity.money != null
        ? "${activity.money! > 0 ? '+' : ''}${MoneyFormatter.format(activity.money!)} ₫"
        : "0 đ";

    // Determine color based on type (defensive: handle empty string)
    final String type = (activity.type.isNotEmpty ? activity.type : 'OTHER')
        .toUpperCase();
    Color baseColor;
    switch (type) {
      case 'EXPENSE':
        baseColor = Colors.red;
        break;
      case 'INCOME':
      case 'PRODUCT':
        baseColor = AppColors.primary_main;
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

  bool _activityOccursOnDate(FinancialActivityEntity activity, DateTime date) {
    // Defensive: require repeat to be present
    if (activity.repeat == null ||
        activity.repeat!.isEmpty ||
        activity.repeat == "Không") {
      return false;
    }

    // If an endRepeatDay exists and the date is after it, it's not occurring
    if (activity.endRepeatDay != null) {
      final end = activity.endRepeatDay!.toLocal();
      if (date.isAfter(DateTime(end.year, end.month, end.day))) return false;
    }

    final start = activity.timeStart.toLocal();
    final repeat = activity.repeat!;

    // Backend already calculated occurrences, so trust it and just match pattern
    // Don't filter by start date since backend handles that logic
    switch (repeat) {
      case 'Hàng ngày':
        return true;
      case 'Hàng tuần':
        return date.weekday == start.weekday;
      case 'Hàng tháng':
        return date.day == start.day;
      case 'Hàng năm':
        return date.day == start.day && date.month == start.month;
      default:
        // Fallback: if repeat stored in english or other formats
        final r = repeat.toLowerCase();
        if (r.contains('daily')) return true;
        if (r.contains('weekly')) return date.weekday == start.weekday;
        if (r.contains('monthly')) return date.day == start.day;
        if (r.contains('yearly') || r.contains('annual'))
          return date.day == start.day && date.month == start.month;
        return false;
    }
  }

  FinancialActivityEntity _activityInstanceForDate(
    FinancialActivityEntity activity,
    DateTime date,
  ) {
    // Build new start/end preserving time-of-day and duration but adjusted to `date`.
    final origStart = activity.timeStart.toLocal();
    final origEnd = activity.timeEnd.toLocal();
    final duration = origEnd.difference(origStart);

    final newStart = DateTime(
      date.year,
      date.month,
      date.day,
      origStart.hour,
      origStart.minute,
      origStart.second,
    );
    final newEnd = newStart.add(duration);

    return FinancialActivityEntity(
      id: activity.id,
      description: activity.description,
      description2: activity.description2,
      description3: activity.description3,
      timeStart: newStart.toUtc(),
      timeEnd: newEnd.toUtc(),
      day: activity.day,
      money: activity.money,
      type: activity.type,
      title: activity.title,
      isRepeat: activity.isRepeat,
      repeat: activity.repeat,
      endRepeatDay: activity.endRepeatDay,
      alertTime: activity.alertTime,
      object: activity.object,
      amount: activity.amount,
      unit: activity.unit,
      purpose: activity.purpose,
      targetPerson: activity.targetPerson,
      sourcePerson: activity.sourcePerson,
      attachedLink: activity.attachedLink,
      note: activity.note,
      createdAt: activity.createdAt,
      updatedAt: activity.updatedAt,
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
