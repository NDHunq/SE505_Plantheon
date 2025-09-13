import 'package:flutter/material.dart';
import 'package:se501_plantheon/presentation/screens/diary/widgets/navigation.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/presentation/screens/diary/widgets/task.dart';
import 'package:se501_plantheon/presentation/screens/diary/billOfMonth.dart';
import 'package:se501_plantheon/presentation/screens/diary/diary.dart';

class BillOfDay extends StatefulWidget {
  final DateTime? initialDate;

  const BillOfDay({super.key, this.initialDate});

  @override
  State<BillOfDay> createState() => _BillOfDayState();
}

class _BillOfDayState extends State<BillOfDay> {
  late DateTime currentMonth;
  late int expandedDay;
  late ScrollController scrollController;
  final Map<int, GlobalKey> dayKeys = {};

  // Dữ liệu mẫu cho các ngày
  final Map<int, List<Transaction>> dailyTransactions = {
    1: [
      Transaction(
        startTime: "6:20",
        endTime: "6:30",
        description: "Mua phân bón",
        amount: -100000,
      ),
    ],
    2: [],
    // Thêm dữ liệu mẫu cho các ngày khác
  };

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

    // Auto scroll to selected day after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDay(expandedDay);
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
      appBar: CustomNavigationBar(
        title: "Báo cáo ngày",
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
      body: Column(
        children: [
          // Tổng kết tháng
          _buildMonthSummary(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  // Header tháng

                  // Danh sách ngày
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _getDaysInMonth(),
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        final isExpanded = day == expandedDay;
                        final transactions = dailyTransactions[day] ?? [];
                        final dayBalance = _calculateDayBalance(transactions);

                        return _buildDayItem(
                          day: day,
                          balance: dayBalance,
                          transactions: transactions,
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
      ),
    );
  }

  Widget _buildMonthSummary() {
    final monthIncome = 200000;
    final monthExpense = 200000;
    final monthBalance = monthIncome - monthExpense;

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BillOfMonth(initialDate: currentMonth),
                    ),
                  );
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

  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstraints.mainPadding,
        vertical: AppConstraints.smallPadding,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              "Ngày",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppConstraints.normalTextFontSize,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "Số dư",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppConstraints.normalTextFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem({
    required int day,
    required int balance,
    required List<Transaction> transactions,
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
                        : "${balance > 0 ? '+' : ''}${balance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
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
        if (isExpanded && transactions.isNotEmpty)
          ...transactions.map(
            (transaction) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstraints.mainPadding,
                vertical: AppConstraints.smallPadding / 2,
              ),
              child: _buildTaskWidget(transaction),
            ),
          ),

        // Divider
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }

  Widget _buildTaskWidget(Transaction transaction) {
    final String amountText =
        "${transaction.amount > 0 ? '+' : ''}${transaction.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ";

    return SizedBox(
      width: double.infinity,
      child: TaskWidget(
        title: transaction.description,
        amountText: amountText,
        startTime: transaction.startTime,
        endTime: transaction.endTime,
        baseColor: Colors.blue,
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
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  int _getDaysInMonth() {
    return DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
  }

  int _calculateDayBalance(List<Transaction> transactions) {
    return transactions.fold(0, (sum, transaction) => sum + transaction.amount);
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

class Transaction {
  final String startTime;
  final String endTime;
  final String description;
  final int amount;

  Transaction({
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.amount,
  });
}

extension BillOfDayExtension on _BillOfDayState {
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
}
