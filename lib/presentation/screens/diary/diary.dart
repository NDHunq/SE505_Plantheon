import 'package:flutter/material.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/common/widgets/topnavigation/navigation.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/presentation/screens/diary/month.dart';
import 'package:se501_plantheon/presentation/screens/diary/addNew.dart';
import 'package:se501_plantheon/presentation/screens/diary/billOfMonth.dart';
import 'package:se501_plantheon/presentation/screens/diary/billOfYear.dart';
import 'package:se501_plantheon/presentation/screens/diary/billOfDay.dart';
import 'package:se501_plantheon/presentation/screens/diary/dayDetail.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

enum DiaryViewType {
  monthGrid,
  monthDetail,
  yearSelector,
  billOfMonth,
  billOfYear,
  billOfDay,
  dayDetail,
}

class Diary extends StatefulWidget {
  const Diary({super.key});

  @override
  State<Diary> createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
  int selectedYear = DateTime.now().year;
  int? selectedMonth;
  int? selectedDay;
  DiaryViewType currentView = DiaryViewType.monthGrid;
  bool isLoading = false;
  DateTime? billDate; // For bill views
  String? customTitle; // For dynamic title
  DiaryViewType? latestCalendarView; // Track latest calendar view accessed
  DateTime? selectedDate; // For add new screen\

  void _setSelectedDate(DateTime date) {
    // Sử dụng post frame callback để tránh gọi setState trong build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          selectedDate = date;
        });
      }
    });
  }

  void _toggleYearSelector() async {
    setState(() {
      isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      currentView = currentView == DiaryViewType.yearSelector
          ? DiaryViewType.monthGrid
          : DiaryViewType.yearSelector;
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
      currentView = DiaryViewType.monthGrid;
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
      currentView = DiaryViewType.monthDetail;
      latestCalendarView = DiaryViewType.monthDetail; // Track calendar view
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
      selectedDay = null;
      currentView = DiaryViewType.monthGrid;
      latestCalendarView = DiaryViewType.monthGrid; // Track calendar view
      customTitle = null; // Reset custom title
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

    setState(() {
      billDate = targetDate;
      currentView = DiaryViewType.billOfMonth;
    });
  }

  void _openBillOfYear(DateTime date) {
    final now = DateTime.now();

    // Kiểm tra nếu là năm tương lai
    if (date.year > now.year) {
      _showFutureWarning();
      return;
    }

    setState(() {
      billDate = date;
      currentView = DiaryViewType.billOfYear;
    });
  }

  void _openBillOfDay(DateTime date) {
    final now = DateTime.now();

    // Kiểm tra nếu là ngày tương lai
    if (date.isAfter(DateTime(now.year, now.month, now.day))) {
      _showFutureWarning();
      return;
    }

    setState(() {
      billDate = date;
      currentView = DiaryViewType.billOfDay;
    });
  }

  void navigateToDay(int day, int month, int year) async {
    setState(() {
      isLoading = true;
    });

    // Simulate loading delay tương tự navigateToMonth
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      selectedDay = day;
      selectedMonth = month;
      selectedYear = year;
      currentView = DiaryViewType.dayDetail;
      latestCalendarView = DiaryViewType.dayDetail; // Track calendar view
      customTitle = null; // Reset custom title
      isLoading = false;
    });
  }

  void updateSelectedDate(int day, int month, int year) {
    setState(() {
      selectedDay = day;
      selectedMonth = month;
      selectedYear = year;
    });
  }

  void changeTitle(String title) {
    setState(() {
      customTitle = title;
    });
  }

  void _backToCalendar() {
    setState(() {
      // Dựa vào currentView để quyết định quay về đâu
      if (currentView == DiaryViewType.billOfMonth) {
        // Từ BillOfMonth → quay về monthGrid (màn hình các tháng trong năm)
        currentView = DiaryViewType.monthGrid;
        latestCalendarView = DiaryViewType.monthGrid; // Track calendar view
        selectedMonth = null;
        selectedDay = null;
        selectedYear = billDate?.year ?? DateTime.now().year;
      } else if (currentView == DiaryViewType.billOfDay) {
        // Từ BillOfDay → dựa vào latestCalendarView để quyết định
        if (latestCalendarView == DiaryViewType.dayDetail) {
          // Nếu latest calendar là dayDetail → quay về dayDetail
          currentView = DiaryViewType.dayDetail;
          selectedMonth = billDate?.month ?? DateTime.now().month;
          selectedYear = billDate?.year ?? DateTime.now().year;
          selectedDay = billDate?.day ?? DateTime.now().day;
        } else {
          // Nếu không → quay về monthDetail (month.dart)
          currentView = DiaryViewType.monthDetail;
          selectedMonth = billDate?.month ?? DateTime.now().month;
          selectedYear = billDate?.year ?? DateTime.now().year;
          selectedDay = null;
        }
      } else {
        // Các trường hợp khác → quay về monthGrid
        currentView = DiaryViewType.monthGrid;
        latestCalendarView = DiaryViewType.monthGrid; // Track calendar view
        selectedMonth = null;
        selectedDay = null;
      }

      billDate = null;
      customTitle = null;
    });
  }

  void _navigateToBillOfMonth(DateTime date) {
    setState(() {
      billDate = date;
      currentView = DiaryViewType.billOfMonth;
    });
  }

  void _navigateToBillOfYear(DateTime date) {
    setState(() {
      billDate = date;
      currentView = DiaryViewType.billOfYear;
    });
  }

  void _navigateToBillOfDay(DateTime date) {
    setState(() {
      billDate = date;
      currentView = DiaryViewType.billOfDay;
    });
  }

  List<NavigationAction> _getActions() {
    // Nếu đang ở bill views, hiển thị calendar action
    if (currentView == DiaryViewType.billOfMonth ||
        currentView == DiaryViewType.billOfYear ||
        currentView == DiaryViewType.billOfDay) {
      return [
        NavigationAction(
          icon: Icons.calendar_month,
          onPressed: _backToCalendar,
        ),
        CommonNavigationActions.search(
          onPressed: () => _showSearchModal(context),
        ),
        CommonNavigationActions.add(onPressed: () => _showAddNewModal(context)),
      ];
    } else {
      // Default actions cho các view khác
      VoidCallback billAction;

      // Nếu đang ở monthDetail hoặc dayDetail, mở billOfDay
      if (currentView == DiaryViewType.monthDetail ||
          currentView == DiaryViewType.dayDetail) {
        billAction = () => _navigateToBillOfDay(
          DateTime(selectedYear, selectedMonth!, selectedDay ?? 1),
        );
      } else {
        // Các view khác mở billOfMonth
        billAction = () => _navigateToBillOfMonth(
          DateTime(selectedYear, selectedMonth ?? DateTime.now().month, 1),
        );
      }

      return [
        NavigationAction(icon: Icons.bar_chart, onPressed: billAction),
        CommonNavigationActions.search(
          onPressed: () => _showSearchModal(context),
        ),
        CommonNavigationActions.add(onPressed: () => _showAddNewModal(context)),
      ];
    }
  }

  bool _shouldShowBackButton() {
    return currentView != DiaryViewType.monthGrid &&
        currentView != DiaryViewType.yearSelector;
  }

  void _handleBackPressed() {
    switch (currentView) {
      case DiaryViewType.dayDetail:
        // Từ dayDetail quay về monthDetail
        setState(() {
          currentView = DiaryViewType.monthDetail;
          latestCalendarView =
              DiaryViewType.monthDetail; // Update latest calendar view
          customTitle = null; // Reset custom title
        });
        break;
      case DiaryViewType.monthDetail:
      case DiaryViewType.billOfMonth:
      case DiaryViewType.billOfYear:
      case DiaryViewType.billOfDay:
        _backToMonthSelection();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DiaryNavigationBar(
        selectedYear: selectedYear,
        selectedMonth: selectedMonth,
        showYearSelector: currentView == DiaryViewType.yearSelector,
        onToggleYearSelector: _toggleYearSelector,
        onBackToMonthSelection: _backToMonthSelection,
        showBackButton: _shouldShowBackButton(),
        onBackPressed: _shouldShowBackButton() ? _handleBackPressed : null,
        customTitle: customTitle,
        actions: _getActions(),
      ),
      body: Stack(
        children: [
          _buildContent(),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [LoadingIndicator(), SizedBox(height: 16)],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (currentView) {
      case DiaryViewType.yearSelector:
        return _buildYearSelector();
      case DiaryViewType.monthDetail:
        return MonthScreen(
          onSelectedDate: _setSelectedDate,
          month: selectedMonth!,
          year: selectedYear,
          onDaySelected: navigateToDay,
        );
      case DiaryViewType.billOfMonth:
        return _BillWrapper(
          child: BillOfMonth(
            initialDate: billDate,
            onTitleChange: changeTitle,
            onBackToCalendar: _backToCalendar,
            onNavigateToBillOfYear: _navigateToBillOfYear,
            onNavigateToBillOfDay: _navigateToBillOfDay,
          ),
        );
      case DiaryViewType.billOfYear:
        return _BillWrapper(
          child: BillOfYear(
            initialDate: billDate,
            onTitleChange: changeTitle,
            onBackToCalendar: _backToCalendar,
            onNavigateToBillOfMonth: _navigateToBillOfMonth,
          ),
        );
      case DiaryViewType.billOfDay:
        return _BillWrapper(
          child: BillOfDay(
            initialDate: billDate,
            onTitleChange: changeTitle,
            onBackToCalendar: _backToCalendar,
            onNavigateToBillOfMonth: _navigateToBillOfMonth,
          ),
        );
      case DiaryViewType.dayDetail:
        return DayDetailScreen(
          onSelectedDate: _setSelectedDate,
          arguments: {
            'day': selectedDay,
            'month': selectedMonth,
            'year': selectedYear,
          },
          onTitleChange: changeTitle,
          onDateChange: updateSelectedDate,
        );
      case DiaryViewType.monthGrid:
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
        child: AddNewScreen(initialDate: selectedDate),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
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
      ),
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
              color: isSelected ? AppColors.primary_600 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isCurrentYear
                  ? Border.all(color: AppColors.primary_600, width: 2)
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

class _BillWrapper extends StatelessWidget {
  final Widget child;

  const _BillWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    // Extract the body content from the Bill widgets by removing Scaffold wrapper
    if (child is StatefulWidget) {
      // For now, return the child as is. We'll need to modify the Bill widgets
      // to not use Scaffold when used as embedded widgets
      return child;
    }
    return child;
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

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () => _navigateToMonth(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrentMonth
                  ? AppColors.primary_600
                  : Colors.grey.shade300,
              width: isCurrentMonth ? 2 : 1,
            ),
            color: isCurrentMonth ? AppColors.primary_50 : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Tháng ${widget.month}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCurrentMonth
                        ? AppColors.primary_600
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$daysInMonth ngày",
                  style: TextStyle(
                    fontSize: 12,
                    color: isCurrentMonth
                        ? AppColors.primary_600
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isCurrentMonth) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary_600,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
