import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/data/models/activities_models.dart';
import 'package:se501_plantheon/data/datasources/activities_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/activities_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/activity/get_activities_by_month.dart';
import 'package:se501_plantheon/domain/usecases/activity/get_activities_by_day.dart';
import 'package:se501_plantheon/domain/usecases/activity/create_activity.dart';
import 'package:se501_plantheon/domain/usecases/activity/update_activity.dart';
import 'package:se501_plantheon/domain/usecases/activity/delete_activity.dart';
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
          deleteActivity: DeleteActivity(repository),
        )..add(FetchActivitiesByMonth(year: widget.year, month: widget.month));
      },
      child: Stack(
        children: [
          Scaffold(
            body: Padding(
              padding: EdgeInsets.all(0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text("T2", style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text("T3", style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text("T4", style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text("T5", style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text("T6", style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text("T7", style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text("CN", style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: BlocBuilder<ActivitiesBloc, ActivitiesState>(
                      builder: (context, state) {
                        if (state is ActivitiesLoading) {
                          return const Center(child: LoadingIndicator());
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
                    children: [LoadingIndicator()],
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
        childAspectRatio: 0.6,
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
        final List<ActivityModel> tasks = _getTasksForDay(
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

  List<ActivityModel> _getTasksForDay(
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
    return match.activities;
  }
}

class ADayWidget extends StatelessWidget {
  final int day;
  final bool isToday;
  final VoidCallback onTap;
  final List<ActivityModel> tasks;

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
        padding: EdgeInsets.only(top: 4.sp, bottom: 4.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Số ngày - cố định ở đầu
            Container(
              width: 28.sp,
              height: 28.sp,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isToday ? AppColors.primary_600 : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$day',
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Colors.white : Colors.black,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SizedBox(height: 8.sp),
            // Phần tasks - co giãn để lấp đầy không gian còn lại
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.sp),
                child: SizedBox(
                  width: double.infinity,
                  child: ArrayTaskWidget(tasks),
                ),
              ),
            ),
            // Gạch dưới - cố định ở cuối
            Container(
              width: double.infinity,
              height: 1.sp,
              color: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class ArrayTaskWidget extends StatelessWidget {
  final List<ActivityModel> tasks;

  const ArrayTaskWidget(this.tasks, {super.key});

  Color _getColorByType(String type) {
    switch (type.toUpperCase()) {
      case 'EXPENSE':
        return Colors.red;
      case 'INCOME':
        return AppColors.primary_main;
      case 'DISEASE':
        return Colors.orange;
      case 'TECHNIQUE':
        return Colors.blue;
      case 'CLIMATE':
        return Colors.teal;
      case 'OTHER':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    final List<ActivityModel> tasksToShow = tasks.length <= 2
        ? tasks
        : tasks.take(2).toList();
    final int remaining = tasks.length - tasksToShow.length;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...tasksToShow.asMap().entries.map((entry) {
          final ActivityModel activity = entry.value;
          final Color bgColor = _getColorByType(activity.type);
          return Container(
            width: double.infinity,
            height: 10.sp,
            margin: EdgeInsets.only(top: 1.sp),
            padding: EdgeInsets.symmetric(horizontal: 2.sp),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4.sp),
            ),
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: const Offset(0, -2),
              child: Text(
                activity.title,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.start,
              ),
            ),
          );
        }),
        if (remaining > 0)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 2.sp),
            child: Text(
              "+$remaining",
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
