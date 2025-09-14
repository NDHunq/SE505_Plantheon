import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/presentation/screens/Navigator/navigator.dart';
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

  // Mock data - thay thế bằng data thật từ API
  final Map<int, List<YearlyTransaction>> yearlyTransactions = {
    2020: [
      YearlyTransaction("Q1/2020", "Lương quý 1", 45000000),
      YearlyTransaction("Q2/2020", "Đầu tư crypto", -10000000),
      YearlyTransaction("Q4/2020", "Bonus cuối năm", 20000000),
    ],
    2021: [
      YearlyTransaction("Q1/2021", "Lương quý 1", 50000000),
      YearlyTransaction("Q3/2021", "Mua nhà", -500000000),
      YearlyTransaction("Q4/2021", "Bonus cuối năm", 25000000),
    ],
    2022: [
      YearlyTransaction("Q1/2022", "Lương quý 1", 55000000),
      YearlyTransaction("Q2/2022", "Đầu tư chứng khoán", -20000000),
      YearlyTransaction("Q4/2022", "Bonus cuối năm", 30000000),
    ],
    2023: [
      YearlyTransaction("Q1/2023", "Lương quý 1", 60000000),
      YearlyTransaction("Q3/2023", "Mua xe", -800000000),
      YearlyTransaction("Q4/2023", "Bonus cuối năm", 35000000),
    ],
    2024: [
      YearlyTransaction("Q1/2024", "Lương quý 1", 65000000),
      YearlyTransaction("Q2/2024", "Thu nhập phụ", 15000000),
      YearlyTransaction("Q3/2024", "Đầu tư bất động sản", -300000000),
    ],
    // Thêm data cho các năm khác nếu cần
  };

  @override
  void initState() {
    super.initState();
    currentDecade = widget.initialDate ?? DateTime.now();

    // Cập nhật title
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onTitleChange != null) {
        widget.onTitleChange!('Báo cáo năm');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tổng kết thập kỷ
        _buildDecadeSummary(),

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
                  _buildYearItem(year, yearlyTransactions[year] ?? []),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecadeSummary() {
    // Tính tổng thu nhập và chi tiêu của thập kỷ
    int decadeIncome = 0;
    int decadeExpense = 0;

    for (int year in _getDecadeYears()) {
      final transactions = yearlyTransactions[year] ?? [];
      for (var transaction in transactions) {
        if (transaction.amount > 0) {
          decadeIncome += transaction.amount;
        } else {
          decadeExpense += transaction.amount.abs();
        }
      }
    }

    int decadeBalance = decadeIncome - decadeExpense;
    final startYear = _getDecadeStart();
    final currentYear = DateTime.now().year;
    final currentDecadeStart = (currentYear ~/ 10) * 10;
    final targetDecadeStart = (currentDecade.year ~/ 10) * 10;

    final endYear = (targetDecadeStart == currentDecadeStart)
        ? currentYear
        : startYear + 9;

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
              if (!_isCurrentDecade())
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
                "+${decadeIncome.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primary_600,
                ),
              ),
              Text(
                "-${decadeExpense.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              Text(
                "= ${decadeBalance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ",
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearItem(int year, List<YearlyTransaction> transactions) {
    final int balance = _calculateYearBalance(transactions);

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
                          : _isFutureYear(year)
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
  }

  void _nextDecade() {
    final currentYear = DateTime.now().year;
    final currentDecadeStart = (currentYear ~/ 10) * 10;
    final targetDecadeStart = (currentDecade.year ~/ 10) * 10;

    // Chỉ cho phép chuyển tiếp nếu chưa đến thập kỷ hiện tại
    if (targetDecadeStart < currentDecadeStart) {
      setState(() {
        currentDecade = DateTime(
          currentDecade.year + 10,
          currentDecade.month,
          currentDecade.day,
        );
      });
    }
  }

  bool _isCurrentDecade() {
    final currentYear = DateTime.now().year;
    final currentDecadeStart = (currentYear ~/ 10) * 10;
    final targetDecadeStart = (currentDecade.year ~/ 10) * 10;
    return targetDecadeStart == currentDecadeStart;
  }

  int _calculateYearBalance(List<YearlyTransaction> transactions) {
    return transactions.fold(0, (sum, transaction) => sum + transaction.amount);
  }

  bool _isCurrentYear(int year) {
    final now = DateTime.now();
    return year == now.year;
  }

  bool _isFutureYear(int year) {
    final now = DateTime.now();
    return year > now.year;
  }

  int _getDecadeStart() {
    final currentYear = DateTime.now().year;
    final currentDecadeStart = (currentYear ~/ 10) * 10;
    final targetDecadeStart = (currentDecade.year ~/ 10) * 10;

    // Nếu đang ở thập kỷ hiện tại, điều chỉnh để kết thúc tại năm hiện tại
    if (targetDecadeStart == currentDecadeStart) {
      return currentYear - 9; // Ví dụ: 2025 -> 2016-2025
    }

    return targetDecadeStart;
  }

  List<int> _getDecadeYears() {
    final startYear = _getDecadeStart();
    final currentYear = DateTime.now().year;
    final currentDecadeStart = (currentYear ~/ 10) * 10;
    final targetDecadeStart = (currentDecade.year ~/ 10) * 10;

    List<int> years = [];

    // Nếu đang ở thập kỷ hiện tại
    if (targetDecadeStart == currentDecadeStart) {
      // Hiển thị từ startYear đến currentYear
      for (int year = startYear; year <= currentYear; year++) {
        years.add(year);
      }
    } else {
      // Hiển thị đầy đủ 10 năm của thập kỷ
      for (int year = startYear; year < startYear + 10; year++) {
        years.add(year);
      }
    }

    return years;
  }
}

class YearlyTransaction {
  final String period; // Định dạng: "Q1/2024" hoặc "2024"
  final String description;
  final int amount;

  YearlyTransaction(this.period, this.description, this.amount);
}
