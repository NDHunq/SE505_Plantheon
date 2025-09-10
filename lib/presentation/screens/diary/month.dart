import 'package:flutter/material.dart';
import 'package:se501_plantheon/shared/constraint.dart';
import 'package:se501_plantheon/presentation/screens/diary/dayDetail.dart';

class MonthScreen extends StatefulWidget {
  final int year;
  final int month;
  
  const MonthScreen({
    super.key,
    required this.year,
    required this.month,
  });

  @override
  State<MonthScreen> createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  bool isLoading = false;

  String _getMonthName(int month) {
    const monthNames = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return monthNames[month - 1];
  }

  Future<void> _navigateToDayDetail(int day) async {
    setState(() {
      isLoading = true;
    });
    
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DayDetailScreen(
            arguments: {
              'day': day,
              'month': widget.month,
              'year': widget.year,
            },
          ),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
         
          body: Padding(
            padding: const EdgeInsets.all(AppConstraints.mainPadding),
            child: Column(
              children: [
               
                Row(
                  children: [
                    Expanded(child: Center(child: Text("T2"))),
                    Expanded(child: Center(child: Text("T3"))),
                    Expanded(child: Center(child: Text("T4"))),
                    Expanded(child: Center(child: Text("T5"))),
                    Expanded(child: Center(child: Text("T6"))),
                    Expanded(child: Center(child: Text("T7"))),
                    Expanded(child: Center(child: Text("CN"))),
                  ],
                ),
                const Divider(),
                
                // Tên tháng (không có navigation)
                
                
                
                Expanded(child: _buildCalendar()),
              ],
            ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
         
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      strokeWidth: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final int year = widget.year;
    final int month = widget.month;
    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    final int firstWeekday = DateTime(year, month, 1).weekday;
    // weekday: 1=Thứ 2, 2=Thứ 3, ..., 7=Chủ nhật
    // Cần chuyển đổi để Thứ 2 = 0, Thứ 3 = 1, ..., Chủ nhật = 6
    final int leadingEmptyCells = (firstWeekday - 1) % 7;
    final int totalCells = ((leadingEmptyCells + daysInMonth) / 7).ceil() * 7;

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.8,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < leadingEmptyCells || index >= leadingEmptyCells + daysInMonth) {
          return const SizedBox.shrink();
        }
        final day = index - leadingEmptyCells + 1;
        final bool isToday = (year == now.year && month == now.month && day == now.day);
        
        return ADayWidget(
          day: day, 
          isToday: isToday,
          onTap: isLoading ? () {} : () => _navigateToDayDetail(day),
        );
      },
    );
  }
}

class ADayWidget extends StatelessWidget {
  final int day;
  final bool isToday;
  final VoidCallback onTap;

  const ADayWidget({
    super.key, 
    required this.day, 
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isToday ? Colors.green : Colors.transparent,
                shape: BoxShape.circle,
              ),

              child: Text(
                '$day',
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                 ArrayTaskWidget(["T1", "T2"]),
                ],
              ),
            ),
            SizedBox(height: 4),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey,
            ),
           
            
          ],
        ),
      ),
    );
  }
}
 
class ArrayTaskWidget extends StatelessWidget {
  final List<String> tasks;

  const ArrayTaskWidget(this.tasks, {super.key});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    final List<String> tasksToShow = tasks.length <= 2 ? tasks : tasks.take(2).toList();
    final int remaining = tasks.length - tasksToShow.length;

    const List<Color> palette = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...tasksToShow.asMap().entries.map((entry) {
          final int idx = entry.key;
          final String t = entry.value;
          final Color bgColor = palette[idx % palette.length];
          return Container(
            width: double.infinity,
            height: 8,
            margin: const EdgeInsets.only(top: 1),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              t,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
            ),
          );
        }),
        if (remaining > 0)
          SizedBox(
            width: double.infinity,
            child: Text(
              "+$remaining",
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
      ],
    );
  }
}