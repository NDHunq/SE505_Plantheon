import 'package:flutter/material.dart';
import 'package:se501_plantheon/presentation/screens/diary/widgets/navigation.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/presentation/screens/diary/billOfYear.dart';
import 'package:se501_plantheon/presentation/screens/diary/billOfDay.dart';
import 'package:se501_plantheon/presentation/screens/diary/diary.dart';

class BillOfMonth extends StatefulWidget {
  final DateTime? initialDate;

  const BillOfMonth({super.key, this.initialDate});

  @override
  State<BillOfMonth> createState() => _BillOfMonthState();
}

class _BillOfMonthState extends State<BillOfMonth> {
  late DateTime currentYear;
  late ScrollController scrollController;

  // Mock data - thay thế bằng data thật từ API
  final Map<int, MonthSummary> monthSummaries = {
    1: MonthSummary(15000000, 1300000),
    2: MonthSummary(15000000, 300000),
    3: MonthSummary(15000000, 25000000),
    4: MonthSummary(16000000, 2000000),
    5: MonthSummary(16000000, 1800000),
    6: MonthSummary(17000000, 2200000),
    7: MonthSummary(17000000, 1900000),
    8: MonthSummary(18000000, 2100000),
    9: MonthSummary(18000000, 2300000),
    10: MonthSummary(19000000, 2400000),
    11: MonthSummary(19000000, 2500000),
    12: MonthSummary(20000000, 3000000),
  };

  @override
  void initState() {
    super.initState();
    currentYear = widget.initialDate ?? DateTime.now();
    scrollController = ScrollController();

    // Auto scroll to selected month after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetMonth = widget.initialDate?.month ?? DateTime.now().month;
      _scrollToMonth(targetMonth);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Navigation Bar
            CustomNavigationBar(
              title: "Báo cáo tháng",
              backgroundColor: Colors.white,
              actions: [
                NavigationAction(
                  icon: Icons.calendar_today,
                  onPressed: () => _navigateWithLoading(context),
                ),
                NavigationAction(icon: Icons.search, onPressed: () {}),
                NavigationAction(icon: Icons.add, onPressed: () {}),
              ],
            ),

            // Tổng kết năm
            _buildYearSummary(),

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
                      _buildMonthItem(month),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSummary() {
    // Tính tổng thu nhập và chi tiêu của năm
    int yearIncome = 0;
    int yearExpense = 0;

    monthSummaries.forEach((month, summary) {
      yearIncome += summary.income;
      yearExpense += summary.expense;
    });

    int yearBalance = yearIncome - yearExpense;

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

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BillOfYear(initialDate: currentYear),
                    ),
                  );
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
                "+${yearIncome.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primary_600,
                ),
              ),
              Text(
                "-${yearExpense.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              Text(
                "= ${yearBalance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthItem(int month) {
    final summary = monthSummaries[month];
    final int income = summary?.income ?? 0;
    final int expense = summary?.expense ?? 0;
    final int balance = income - expense;
    final String monthName = _getMonthName(month);

    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BillOfDay(
                  initialDate: DateTime(currentYear.year, month, 1),
                ),
              ),
            );
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
                        "+${income.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary_600,
                        ),
                      ),
                      Text(
                        "-${expense.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                      Text(
                        "= ${balance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
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

class MonthSummary {
  final int income;
  final int expense;

  MonthSummary(this.income, this.expense);
}

extension BillOfMonthExtension on _BillOfMonthState {
  void _navigateWithLoading(BuildContext context) {
    // Hiển thị loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary_600),
        );
      },
    );

    // Simulate loading delay và navigate
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pop(); // Đóng loading dialog
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Diary()),
        (route) => false,
      );
    });
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
}
