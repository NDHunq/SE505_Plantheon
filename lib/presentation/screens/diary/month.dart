import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/data/models/activities_models.dart';
import 'package:se501_plantheon/data/datasources/activities_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/activities_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/get_activities_by_month.dart';
import 'package:se501_plantheon/domain/usecases/get_activities_by_day.dart';
import 'package:se501_plantheon/domain/usecases/create_activity.dart';
import 'package:se501_plantheon/domain/usecases/update_activity.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_event.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_state.dart';
import 'package:se501_plantheon/presentation/screens/diary/dayDetail.dart';

class MonthScreen extends StatefulWidget {
  final int year;
  final int month;
  final Function(DateTime date)? onSelectedDate;
  final Function(int day, int month, int year)? onDaySelected;

  const MonthScreen({
    super.key,
    required this.year,
    required this.month,
    this.onSelectedDate,
    this.onDaySelected,
  });

  @override
  State<MonthScreen> createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.onSelectedDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSelectedDate!(DateTime.now());
      });
    }
  }

  bool isLoading = false;

  Future<void> _navigateToDayDetail(int day) async {
    setState(() {
      isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      // Nếu có callback, gọi callback thay vì Navigator.push
      if (widget.onDaySelected != null) {
        widget.onDaySelected!(day, widget.month, widget.year);
        setState(() {
          isLoading = false;
        });
      } else {
        // Fallback cho trường hợp không có callback
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repository = ActivitiesRepositoryImpl(
          remoteDataSource: ActivitiesRemoteDataSourceImpl(
            client: http.Client(),
          ),
        );
        return ActivitiesBloc(
          getActivitiesByMonth: GetActivitiesByMonth(repository),
          getActivitiesByDay: GetActivitiesByDay(repository),
          createActivity: CreateActivity(repository),
          updateActivity: UpdateActivity(repository),
        )..add(FetchActivitiesByMonth(year: widget.year, month: widget.month));
      },
      child: Stack(
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
                  Expanded(
                    child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
                      builder: (context, state) {
                        if (state is ActivitiesLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state is ActivitiesLoaded) {
                          return _buildCalendar(state);
                        }
                        if (state is ActivitiesError) {
                          return Center(child: Text(state.message));
                        }
                        return _buildCalendar(null);
                      },
                    ),
                  ),
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
      ),
    );
  }

  Widget _buildCalendar(ActivitiesLoaded? loadedState) {
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
        if (index < leadingEmptyCells ||
            index >= leadingEmptyCells + daysInMonth) {
          return const SizedBox.shrink();
        }
        final day = index - leadingEmptyCells + 1;
        final bool isToday =
            (year == now.year && month == now.month && day == now.day);

        // Build tasks for this day
        final List<String> tasks = _getTasksForDay(
          day,
          month,
          year,
          loadedState,
        );

        return ADayWidget(
          day: day,
          isToday: isToday,
          onTap: isLoading ? () {} : () => _navigateToDayDetail(day),
          tasks: tasks,
        );
      },
    );
  }

  List<String> _getTasksForDay(
    int day,
    int month,
    int year,
    ActivitiesLoaded? loadedState,
  ) {
    if (loadedState == null) return const [];
    final days = loadedState.data.days;
    final match = days.firstWhere(
      (d) => d.date.year == year && d.date.month == month && d.date.day == day,
      orElse: () => DayActivitiesModel(
        date: DateTime(year, month, day),
        activities: const [],
      ),
    );
    return match.activities.map((a) => a.title).toList();
  }
}

class ADayWidget extends StatelessWidget {
  final int day;
  final bool isToday;
  final VoidCallback onTap;
  final List<String> tasks;

  const ADayWidget({
    super.key,
    required this.day,
    required this.isToday,
    required this.onTap,
    required this.tasks,
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
              width: 28,
              height: 28,
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
                children: [ArrayTaskWidget(tasks)],
              ),
            ),
            SizedBox(height: 4),
            Container(width: double.infinity, height: 1, color: Colors.grey),
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
    final List<String> tasksToShow = tasks.length <= 2
        ? tasks
        : tasks.take(2).toList();
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
