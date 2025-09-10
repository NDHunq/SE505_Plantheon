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
              Expanded(
                child: _buildHourlySchedule(),
              ),
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
    final DateTime selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
    final List<DateTime> weekDates = List.generate(
      7,
      (index) => selectedDate.add(Duration(days: index - 3)),
    );
    final List<String> weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

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
              final bool isSelected = (d.year == selectedYear && d.month == selectedMonth && d.day == selectedDay);
              final DateTime today = DateTime.now();
              final bool isToday = (d.year == today.year && d.month == today.month && d.day == today.day);
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
                            : (isToday ? Border.all(color: Colors.green, width: 2) : null),
                      ),
                      child: Center(
                        child: Text(
                          '${d.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
            child: const Icon(
              Icons.cloud,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Weather Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hôm nay, Mưa có sấm chớp',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlySchedule() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Time labels and events
          Expanded(
            child: ListView.builder(
              itemCount: 24,
              itemBuilder: (context, index) {
                final hour = index;
                final timeString = '${hour.toString().padLeft(2, '0')}:00';
                
                return Container(
                  height: 60,
                  child: Row(
                    children: [
                      // Time label
                      SizedBox(
                        width: 50,
                        child: Text(
                          timeString,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      
                      // Time line
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: _buildEventForHour(hour),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventForHour(int hour) {
    // Sample events for demonstration
    if (hour == 4) {
      return Container(
        margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: Colors.blue.shade400,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mua phân bón',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '-100 000 đ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (hour == 7) {
      return Container(
        margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: Colors.blue.shade400,
              width: 3,
            ),
          ),
        ),
        child: const Text(
          'You can add events here with the properties!',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}
