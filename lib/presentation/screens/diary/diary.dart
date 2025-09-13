import 'package:flutter/material.dart';
import 'package:se501_plantheon/presentation/screens/diary/widgets/navigation.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/presentation/screens/diary/month.dart';
import 'package:se501_plantheon/presentation/screens/diary/addNew.dart';
import 'package:se501_plantheon/presentation/screens/diary/billOfMonth.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class Diary extends StatefulWidget {
  const Diary({super.key});

  @override
  State<Diary> createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
  int selectedYear = DateTime.now().year;
  int? selectedMonth;
  bool showYearSelector = false;
  bool isLoading = false;

  void _toggleYearSelector() async {
    setState(() {
      isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      showYearSelector = !showYearSelector;
      isLoading = false;
    });
  }

  void _selectYear(int year) async {
    setState(() {
      isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      selectedYear = year;
      showYearSelector = false;
      isLoading = false;
    });
  }

  void _selectMonth(int month) async {
    setState(() {
      isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      selectedMonth = month;
      showYearSelector = false;
      isLoading = false;
    });
  }

  void _backToMonthSelection() async {
    setState(() {
      isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      selectedMonth = null;
      isLoading = false;
    });
  }

  void _openBillOfMonth() {
    final now = DateTime.now();
    final targetDate = DateTime(selectedYear, selectedMonth ?? now.month, 1);

    // Kiểm tra nếu là tháng/năm tương lai
    if (targetDate.isAfter(DateTime(now.year, now.month, 1))) {
      _showFutureWarning();
      return;
    }

    _navigateWithLoading(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BillOfMonth(initialDate: targetDate),
        ),
      );
    });
  }

  void _navigateWithLoading(VoidCallback navigationAction) {
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
      navigationAction(); // Thực hiện navigation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DiaryNavigationBar(
        selectedYear: selectedYear,
        selectedMonth: selectedMonth,
        showYearSelector: showYearSelector,
        onToggleYearSelector: _toggleYearSelector,
        onBackToMonthSelection: _backToMonthSelection,
        showBackButton: selectedMonth != null,
        onBackPressed: selectedMonth != null ? _backToMonthSelection : null,
        actions: [
          NavigationAction(
            icon: Icons.bar_chart,
            onPressed: () => _openBillOfMonth(),
          ),
          CommonNavigationActions.search(
            onPressed: () => _showSearchModal(context),
          ),
          CommonNavigationActions.add(
            onPressed: () => _showAddNewModal(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstraints.mainPadding),
            child: _buildContent(),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (showYearSelector) {
      return _buildYearSelector();
    } else if (selectedMonth != null) {
      return MonthScreen(month: selectedMonth!, year: selectedYear);
    } else {
      return _buildMonthGrid();
    }
  }

  void _showAddNewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const AddNewScreen(),
      ),
    );
  }

  void _showSearchModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tìm kiếm nhật ký"),
        content: const TextField(
          decoration: InputDecoration(
            hintText: "Nhập từ khóa tìm kiếm...",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tìm"),
          ),
        ],
      ),
    );
  }

  /// Lazy load 12 tháng
  Widget _buildMonthGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return MonthWidget(
          key: ValueKey("$selectedYear-${index + 1}"),
          month: index + 1,
          year: selectedYear,
          onMonthSelected: _selectMonth,
        );
      },
    );
  }

  /// Grid chọn năm (3 năm 1 hàng)
  Widget _buildYearSelector() {
    final startYear = 2000;
    final endYear = 2100;
    final years = List.generate(endYear - startYear + 1, (i) => startYear + i);
    final currentYear = DateTime.now().year;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2,
      ),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        final isSelected = year == selectedYear;
        final isCurrentYear = year == currentYear;

        return GestureDetector(
          onTap: isLoading ? null : () => _selectYear(year),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isCurrentYear
                  ? Border.all(color: Colors.red, width: 2)
                  : null,
            ),
            child: Text(
              "$year",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
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

class MonthWidget extends StatefulWidget {
  final int month;
  final int year;
  final Function(int)? onMonthSelected;

  const MonthWidget({
    super.key,
    required this.month,
    required this.year,
    this.onMonthSelected,
  });

  @override
  State<MonthWidget> createState() => _MonthWidgetState();
}

class _MonthWidgetState extends State<MonthWidget> {
  void _navigateToMonth(BuildContext context) {
    if (widget.onMonthSelected != null) {
      widget.onMonthSelected!(widget.month);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MonthScreen(month: widget.month, year: widget.year),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final bool isCurrentMonth =
        (now.year == widget.year && now.month == widget.month);
    final int daysInMonth = DateUtils.getDaysInMonth(widget.year, widget.month);

    return GestureDetector(
      onTap: () => _navigateToMonth(context),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tháng ${widget.month}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCurrentMonth ? Colors.green : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                  ),
                  itemCount: daysInMonth,
                  itemBuilder: (context, day) {
                    final bool isToday = isCurrentMonth && (day + 1 == now.day);

                    return Center(
                      child: isToday
                          ? Container(
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "${day + 1}",
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${day + 1}",
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
