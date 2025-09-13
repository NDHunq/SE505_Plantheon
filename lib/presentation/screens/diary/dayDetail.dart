import 'package:flutter/material.dart';
import 'package:se501_plantheon/presentation/screens/diary/addNew.dart';
import 'package:se501_plantheon/presentation/screens/diary/widget/navigation.dart';

class DayDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const DayDetailScreen({super.key, this.arguments});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  int selectedDay = DateTime.now().day;
  bool isLoading = false;

  // Demo danh sách task theo giờ có thời gian bắt đầu/kết thúc
  final List<_DayEvent> _events = [
    _DayEvent(
      startHour: 4,
      endHour: 6,
      title: 'Mua phân bón và ghi chú rất dài để test overflow ellipsis',
      amountText: '-100 000 đ',
      color: Colors.blue,
    ),
    _DayEvent(
      startHour: 7,
      endHour: 8,
      title: 'Bạn có thể thêm sự kiện tại đây',
      color: Colors.green,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      selectedYear = widget.arguments!['year'] ?? DateTime.now().year;
      selectedMonth = widget.arguments!['month'] ?? DateTime.now().month;
      selectedDay = widget.arguments!['day'] ?? DateTime.now().day;
    }

    // Show loading briefly when navigating from MonthScreen
    _showInitialLoading();
  }

  Future<void> _showInitialLoading() async {
    setState(() {
      isLoading = true;
    });

    // Simulate loading delay for DayDetail
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomNavigationBar(
        title: "$selectedDay/$selectedMonth/$selectedYear",
        showBackButton: true,

        actions: [
          CommonNavigationActions.edit(
            onPressed: () => _showEditModal(context),
          ),
          CommonNavigationActions.add(
            onPressed: () => _showAddNewModal(context),
          ),
          CommonNavigationActions.share(
            onPressed: () => _showShareModal(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Weekday and Date Header
              _buildDateHeader(),

              // Weather Widget
              _buildWeatherWidget(),

              // All Day Events
              _buildAllDayEvents(),

              // Hourly Schedule
              Expanded(child: _buildHourlySchedule()),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showEditModal(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      isLoading = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chỉnh sửa ngày"),
        content: const Text("Chức năng chỉnh sửa sẽ được thêm sau"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  void _showAddNewModal(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      isLoading = false;
    });

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

  void _showShareModal(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      isLoading = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chia sẻ ngày"),
        content: const Text("Chia sẻ thông tin ngày này"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Chia sẻ"),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    // Build a centered 7-day range around the selected date and allow selection
    final DateTime selectedDate = DateTime(
      selectedYear,
      selectedMonth,
      selectedDay,
    );
    final List<DateTime> weekDates = List.generate(
      7,
      (index) => selectedDate.add(Duration(days: index - 3)),
    );
    final List<String> weekdayLabels = [
      'T2',
      'T3',
      'T4',
      'T5',
      'T6',
      'T7',
      'CN',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Weekdays
          Row(
            children: weekDates.map((d) {
              final String label = weekdayLabels[(d.weekday - 1) % 7];
              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Dates
          Row(
            children: weekDates.map((d) {
              final bool isSelected =
                  (d.year == selectedYear &&
                  d.month == selectedMonth &&
                  d.day == selectedDay);
              final DateTime today = DateTime.now();
              final bool isToday =
                  (d.year == today.year &&
                  d.month == today.month &&
                  d.day == today.day);
              return Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedYear = d.year;
                        selectedMonth = d.month;
                        selectedDay = d.day;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? null
                            : (isToday
                                  ? Border.all(color: Colors.green, width: 2)
                                  : null),
                      ),
                      child: Center(
                        child: Text(
                          '${d.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Weather Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 12),

          // Weather Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hôm nay, Mưa có sấm chớp',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '28°C',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllDayEvents() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Cả ngày',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'New Year',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlySchedule() {
    const double hourHeight = 60; // chiều cao 1 giờ
    const double minEventHeight = 56; // tối thiểu để không overflow
    final double totalHeight = 24 * hourHeight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: SizedBox(
              height: totalHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cột giờ bên trái
                  SizedBox(
                    width: 50,
                    child: Column(
                      children: List.generate(24, (i) {
                        final label = '${i.toString().padLeft(2, '0')}:00';
                        return SizedBox(
                          height: hourHeight,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Khu vực timeline và events
                  Expanded(
                    child: Stack(
                      children: [
                        // Vẽ lưới các đường giờ
                        ...List.generate(25, (i) {
                          final double top = i * hourHeight;
                          return Positioned(
                            top: top,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                          );
                        }),

                        // Vẽ các event phủ theo start-end
                        ..._events.map((e) {
                          final double top = e.startHour * hourHeight;
                          final double height = (e.durationHours * hourHeight)
                              .toDouble()
                              .clamp(minEventHeight, double.infinity);
                          return Positioned(
                            top: top,
                            left: 0,
                            right: 0,
                            height: height,
                            child: _buildEventCard(e),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(_DayEvent event) {
    final Color baseColor = event.color ?? Colors.blue;
    final bool isShort = event.durationHours <= 1;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.only(right: 8, top: 0, bottom: 0),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: isShort ? 6 : 8),
        decoration: BoxDecoration(
          color: baseColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: baseColor, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              event.title,
              maxLines: isShort ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (event.amountText != null) ...[
              SizedBox(height: isShort ? 1 : 2),
              Text(
                event.amountText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            SizedBox(height: isShort ? 2 : 4),
            Text(
              '${event.startHour.toString().padLeft(2, '0')}:00 - ${event.endHour.toString().padLeft(2, '0')}:00',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _DayEvent? _findEventStartingAt(int hour) {
    try {
      return _events.firstWhere((e) => e.startHour == hour);
    } catch (_) {
      return null;
    }
  }
}

class _DayEvent {
  final int startHour;
  final int endHour;
  final String title;
  final String? amountText;
  final Color? color;

  _DayEvent({
    required this.startHour,
    required this.endHour,
    required this.title,
    this.amountText,
    this.color,
  }) : assert(endHour >= startHour);

  int get durationHours => (endHour - startHour).clamp(1, 24);
}
