import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/data/datasources/activities_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/activities_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/get_activities_by_day.dart';
import 'package:se501_plantheon/domain/usecases/get_activities_by_month.dart';
import 'package:se501_plantheon/domain/usecases/create_activity.dart';
import 'package:se501_plantheon/domain/usecases/update_activity.dart';
import 'package:se501_plantheon/domain/usecases/delete_activity.dart';
import 'package:se501_plantheon/domain/entities/activities_entities.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_event.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_state.dart';
import 'package:se501_plantheon/presentation/screens/diary/addNew.dart';
import 'package:se501_plantheon/presentation/screens/diary/billOfDay.dart';
import 'package:se501_plantheon/presentation/screens/diary/chiTieu.dart';
import 'package:se501_plantheon/presentation/screens/diary/banSanPham.dart';
import 'package:se501_plantheon/presentation/screens/diary/dichBenh.dart';
import 'package:se501_plantheon/presentation/screens/diary/kyThuat.dart';
import 'package:se501_plantheon/presentation/screens/diary/climamate.dart';
import 'package:se501_plantheon/presentation/screens/diary/other.dart';
import 'package:se501_plantheon/presentation/screens/diary/editView.dart';
import 'package:se501_plantheon/presentation/screens/diary/widgets/task.dart';
import 'package:se501_plantheon/presentation/screens/diary/models/day_event.dart';
import 'package:se501_plantheon/presentation/screens/diary/helpers/day_event_mapper.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/presentation/screens/navigator/navigator.dart';

class DayDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  final Function(String)? onTitleChange;
  final Function(int day, int month, int year)? onDateChange;
  final Function(DateTime date)? onSelectedDate;

  const DayDetailScreen({
    super.key,
    this.arguments,
    this.onTitleChange,
    this.onDateChange,
    this.onSelectedDate,
  });

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  int selectedDay = DateTime.now().day;
  late ActivitiesBloc _activitiesBloc;

  @override
  void initState() {
    super.initState();
    // Parse arguments trước
    if (widget.arguments != null) {
      selectedYear = widget.arguments!['year'] ?? DateTime.now().year;
      selectedMonth = widget.arguments!['month'] ?? DateTime.now().month;
      selectedDay = widget.arguments!['day'] ?? DateTime.now().day;
    }

    // Sau đó gọi callback với giá trị đã được parse (sử dụng post frame callback để đảm bảo widget đã được layout)
    if (widget.onSelectedDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSelectedDate!(
          DateTime(selectedYear, selectedMonth, selectedDay),
        );
      });
    }

    // Khởi tạo bloc
    final repository = ActivitiesRepositoryImpl(
      remoteDataSource: ActivitiesRemoteDataSourceImpl(client: http.Client()),
    );
    _activitiesBloc = ActivitiesBloc(
      getActivitiesByMonth: GetActivitiesByMonth(repository),
      getActivitiesByDay: GetActivitiesByDay(repository),
      createActivity: CreateActivity(repository),
      updateActivity: UpdateActivity(repository),
      deleteActivity: DeleteActivity(repository),
    );

    // Fetch dữ liệu ban đầu
    final String initialDateIso =
        '${selectedYear.toString().padLeft(4, '0')}-'
        '${selectedMonth.toString().padLeft(2, '0')}-'
        '${selectedDay.toString().padLeft(2, '0')}';
    _activitiesBloc.add(FetchActivitiesByDay(dateIso: initialDateIso));

    // Gọi callback để cập nhật title
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onTitleChange != null) {
        final monthNames = [
          'Tháng 1',
          'Tháng 2',
          'Tháng 3',
          'Tháng 4',
          'Tháng 5',
          'Tháng 6',
          'Tháng 7',
          'Tháng 8',
          'Tháng 9',
          'Tháng 10',
          'Tháng 11',
          'Tháng 12',
        ];
        final monthName = monthNames[selectedMonth - 1];
        widget.onTitleChange!('$selectedDay $monthName $selectedYear');
      }
    });
  }

  @override
  void dispose() {
    _activitiesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _activitiesBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<ActivitiesBloc, ActivitiesState>(
          builder: (context, state) {
            final List<DayEvent> events = state is DayActivitiesLoaded
                ? DayEventMapper.mapDayActivitiesToEvents(
                    state,
                    DateTime(selectedYear, selectedMonth, selectedDay),
                  )
                : [];

            if (state is DayActivitiesLoaded) {
              final d = state.data;
              print(
                '[DayDetail] Loaded activities for date=${d.date.toIso8601String()}, count=${d.count}',
              );
              for (final a in d.activities) {
                print(
                  '[DayDetail] Activity: id=${a.id}, title=${a.title}, type=${a.type}, start=${a.timeStart.toIso8601String()}, end=${a.timeEnd.toIso8601String()}',
                );
              }
            }

            return Column(
              children: [
                _buildDateHeader(),
                _buildWeatherWidget(),
                _buildAllDayEvents(),
                Expanded(child: _buildHourlySchedule(events)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context) async {
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
    // Truyền ngày hiện tại đang được chọn
    final selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);

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

  void _showShareModal(BuildContext context) async {
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
                      // Fetch activities for the newly selected day
                      final String dateIso =
                          '${d.year.toString().padLeft(4, '0')}-'
                          '${d.month.toString().padLeft(2, '0')}-'
                          '${d.day.toString().padLeft(2, '0')}';

                      // Gọi API với bloc instance đã tồn tại
                      _activitiesBloc.add(
                        FetchActivitiesByDay(dateIso: dateIso),
                      );

                      setState(() {
                        selectedYear = d.year;
                        selectedMonth = d.month;
                        selectedDay = d.day;
                      });

                      // Cập nhật date trong Diary để khi back lại hiển thị đúng tháng
                      if (widget.onDateChange != null) {
                        widget.onDateChange!(
                          selectedDay,
                          selectedMonth,
                          selectedYear,
                        );
                      }

                      // Cập nhật selectedDate callback
                      if (widget.onSelectedDate != null) {
                        widget.onSelectedDate!(
                          DateTime(selectedYear, selectedMonth, selectedDay),
                        );
                      }

                      // Cập nhật title khi chọn ngày khác
                      if (widget.onTitleChange != null) {
                        final monthNames = [
                          'Tháng 1',
                          'Tháng 2',
                          'Tháng 3',
                          'Tháng 4',
                          'Tháng 5',
                          'Tháng 6',
                          'Tháng 7',
                          'Tháng 8',
                          'Tháng 9',
                          'Tháng 10',
                          'Tháng 11',
                          'Tháng 12',
                        ];
                        final monthName = monthNames[selectedMonth - 1];
                        widget.onTitleChange!(
                          '$selectedDay $monthName $selectedYear',
                        );
                      }
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
            child: const Icon(Icons.cloud, color: Colors.green, size: 25),
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
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      builder: (context, state) {
        // Lọc các activities có day = true
        final allDayActivities = state is DayActivitiesLoaded
            ? state.data.activities.where((activity) => activity.day).toList()
            : <DayActivityDetailEntity>[];

        if (allDayActivities.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cả ngày',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...allDayActivities.map((activity) {
                return GestureDetector(
                  onTap: () => _showEditActivityBottomSheet(activity),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _getTypeDisplayText(activity.type),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.green.shade700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _getTypeDisplayText(String type) {
    switch (type.toUpperCase()) {
      case 'EXPENSE':
        return 'Chi tiêu';
      case 'INCOME':
        return 'Thu nhập';
      case 'TECHNIQUE':
        return 'Kỹ thuật';
      case 'DISEASE':
        return 'Dịch bệnh';
      case 'CLIMATE':
        return 'Thích ứng BĐKH';
      case 'OTHER':
        return 'Khác';
      default:
        return type;
    }
  }

  // Tính toán các task overlap với nhau
  List<List<DayEvent>> _calculateOverlappingGroups(List<DayEvent> events) {
    final List<DayEvent> sortedEvents = [...events]
      ..sort((a, b) => a.startHour.compareTo(b.startHour));

    final List<List<DayEvent>> groups = [];

    for (final event in sortedEvents) {
      bool addedToGroup = false;

      // Tìm group có task overlap với event hiện tại
      for (final group in groups) {
        bool overlaps = false;
        for (final existingEvent in group) {
          // Kiểm tra xem event có giao với existingEvent không
          if (!(event.endHour <= existingEvent.startHour ||
              event.startHour >= existingEvent.endHour)) {
            overlaps = true;
            break;
          }
        }

        if (overlaps) {
          group.add(event);
          addedToGroup = true;
          break;
        }
      }

      if (!addedToGroup) {
        groups.add([event]);
      }
    }

    return groups;
  }

  // Tính toán vị trí và width cho mỗi event
  Map<DayEvent, Map<String, double>> _calculateEventPositions(
    List<DayEvent> events,
  ) {
    final overlappingGroups = _calculateOverlappingGroups(events);
    final Map<DayEvent, Map<String, double>> positions = {};

    for (final group in overlappingGroups) {
      if (group.length == 1) {
        // Không có overlap, dùng full width
        positions[group[0]] = {'left': 0, 'width': 1.0};
      } else {
        // Có overlap, chia đều width
        final double width = 1.0 / group.length;
        for (int i = 0; i < group.length; i++) {
          positions[group[i]] = {'left': i * width, 'width': width};
        }
      }
    }

    return positions;
  }

  Widget _buildHourlySchedule(List<DayEvent> events) {
    const double hourHeight = 60; // chiều cao 1 giờ
    const double minEventHeight = 56; // tối thiểu để không overflow
    final double totalHeight = 25 * hourHeight;

    final eventPositions = _calculateEventPositions(events);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth - 50;

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: totalHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cột giờ bên trái
                      SizedBox(
                        width: 50,
                        child: Column(
                          children: List.generate(25, (i) {
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

                            // Vẽ các event phủ theo start-end với vị trí đã tính toán
                            ...events.map((e) {
                              final double top = e.startHour * hourHeight;
                              final double height =
                                  (e.durationHours * hourHeight)
                                      .toDouble()
                                      .clamp(minEventHeight, double.infinity);

                              final position = eventPositions[e]!;
                              final double leftFraction = position['left']!;
                              final double widthFraction = position['width']!;

                              return Positioned(
                                top: top,
                                left: leftFraction * availableWidth,
                                width: widthFraction * availableWidth,
                                height: height,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 2.0),
                                  child: _buildEventCard(e),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Thêm padding dưới cùng để đẩy nội dung lên
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(DayEvent event) {
    final Color baseColor = event.color ?? Colors.blue;
    final bool isShort = event.durationHours <= 1;

    // Format thời gian thực tế từ database
    final String startTimeStr =
        '${event.realStartTime.day.toString().padLeft(2, '0')}/'
        '${event.realStartTime.month.toString().padLeft(2, '0')} '
        '${event.realStartTime.hour.toString().padLeft(2, '0')}:'
        '${event.realStartTime.minute.toString().padLeft(2, '0')}';

    final String endTimeStr =
        '${event.realEndTime.day.toString().padLeft(2, '0')}/'
        '${event.realEndTime.month.toString().padLeft(2, '0')} '
        '${event.realEndTime.hour.toString().padLeft(2, '0')}:'
        '${event.realEndTime.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => _handleActivityTap(event),
      child: TaskWidget(
        title: event.title,
        amountText: event.amountText,
        startTime: startTimeStr,
        endTime: endTimeStr,
        baseColor: baseColor,
        isShort: isShort,
      ),
    );
  }

  void _handleActivityTap(DayEvent event) {
    // Xử lý cho các activity type được hỗ trợ
    final supportedTypes = [
      'EXPENSE',
      'DISEASE',
      'TECHNIQUE',
      'CLIMATE',
      'OTHER',
      'INCOME',
    ];
    if (!supportedTypes.contains(event.type.toUpperCase())) {
      return;
    }

    // Lấy activity entity từ state để có đầy đủ thông tin
    final state = _activitiesBloc.state;
    if (state is! DayActivitiesLoaded) return;

    final activity = state.data.activities.firstWhere(
      (a) => a.id == event.id,
      orElse: () => throw Exception('Activity not found'),
    );

    _showEditActivityBottomSheet(activity);
  }

  void _refreshCurrentDayActivities() {
    final String dateIso =
        '${selectedYear.toString().padLeft(4, '0')}-'
        '${selectedMonth.toString().padLeft(2, '0')}-'
        '${selectedDay.toString().padLeft(2, '0')}';
    _activitiesBloc.add(
      FetchActivitiesByDay(dateIso: dateIso, showLoading: false),
    );
  }

  void _showEditActivityBottomSheet(DayActivityDetailEntity activity) {
    // Chọn widget phù hợp dựa trên type
    Widget contentWidget;
    switch (activity.type.toUpperCase()) {
      case 'EXPENSE':
        contentWidget = chiTieuWidget(
          activityToEdit: activity,
          bloc: _activitiesBloc,
          initialDate: DateTime(selectedYear, selectedMonth, selectedDay),
          onSubmitSuccess: _refreshCurrentDayActivities,
        );
        break;
      case 'INCOME':
        contentWidget = banSanPhamWidget(
          activityToEdit: activity,
          bloc: _activitiesBloc,
          initialDate: DateTime(selectedYear, selectedMonth, selectedDay),
          onSubmitSuccess: _refreshCurrentDayActivities,
        );
        break;
      case 'DISEASE':
        contentWidget = dichBenhWidget(
          activityToEdit: activity,
          bloc: _activitiesBloc,
          initialDate: DateTime(selectedYear, selectedMonth, selectedDay),
          onSubmitSuccess: _refreshCurrentDayActivities,
        );
        break;
      case 'TECHNIQUE':
        contentWidget = kyThuatWidget(
          activityToEdit: activity,
          bloc: _activitiesBloc,
          initialDate: DateTime(selectedYear, selectedMonth, selectedDay),
          onSubmitSuccess: _refreshCurrentDayActivities,
        );
        break;
      case 'CLIMATE':
        contentWidget = climaMateWidget(
          activityToEdit: activity,
          bloc: _activitiesBloc,
          initialDate: DateTime(selectedYear, selectedMonth, selectedDay),
          onSubmitSuccess: _refreshCurrentDayActivities,
        );
        break;
      case 'OTHER':
        contentWidget = otherWidget(
          activityToEdit: activity,
          bloc: _activitiesBloc,
          initialDate: DateTime(selectedYear, selectedMonth, selectedDay),
          onSubmitSuccess: _refreshCurrentDayActivities,
        );
        break;
      default:
        // Fallback to chiTieuWidget for unsupported types
        contentWidget = chiTieuWidget(
          activityToEdit: activity,
          bloc: _activitiesBloc,
          initialDate: DateTime(selectedYear, selectedMonth, selectedDay),
          onSubmitSuccess: _refreshCurrentDayActivities,
        );
    }

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
        child: EditViewScreen(contentWidget: contentWidget),
      ),
    ).then((_) {
      // Sau khi đóng dialog, refresh lại data
      final String dateIso =
          '${selectedYear.toString().padLeft(4, '0')}-'
          '${selectedMonth.toString().padLeft(2, '0')}-'
          '${selectedDay.toString().padLeft(2, '0')}';
      _activitiesBloc.add(FetchActivitiesByDay(dateIso: dateIso));
    });
  }

  DayEvent? _findEventStartingAt(int hour) {
    try {
      // Not used with BLoC data; kept for potential future feature
      return null;
    } catch (_) {
      return null;
    }
  }

  void _showBillModal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillOfDay(initialDate: DateTime.now()),
      ),
    );
  }
}

extension DayDetailExtension on _DayDetailScreenState {
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
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => Navigation(tab: 2)),
      //   (route) => false,
      // );
    });
  }

  void _openBillOfDay() {
    _navigateWithLoadingToBillOfDay(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BillOfDay(
            initialDate: DateTime(selectedYear, selectedMonth, selectedDay),
          ),
        ),
      );
    });
  }

  void _navigateWithLoadingToBillOfDay(VoidCallback navigationAction) {
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

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      onDestinationSelected: (int index) {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => Navigation(tab: index)),
        // );
      },
      height: 56,
      indicatorColor: Colors.transparent,
      destinations: [
        NavigationDestination(
          selectedIcon: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SvgPicture.asset(
              AppVectors.homeSolid,
              height: 23,
              width: 23,
            ),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SvgPicture.asset(
              AppVectors.homeStroke,
              height: 23,
              width: 23,
            ),
          ),
          label: '',
        ),
        NavigationDestination(
          selectedIcon: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SvgPicture.asset(
              AppVectors.diarySolid,
              height: 23,
              width: 23,
            ),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SvgPicture.asset(
              AppVectors.diaryStroke,
              height: 23,
              width: 23,
            ),
          ),
          label: '',
        ),
        NavigationDestination(
          selectedIcon: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SvgPicture.asset(
              AppVectors.communitySolid,
              height: 23,
              width: 23,
            ),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SvgPicture.asset(
              AppVectors.communityStroke,
              height: 23,
              width: 23,
            ),
          ),
          label: '',
        ),
        NavigationDestination(
          selectedIcon: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SvgPicture.asset(
              AppVectors.accountSolid,
              height: 23,
              width: 23,
            ),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SvgPicture.asset(
              AppVectors.accountStroke,
              height: 23,
              width: 23,
            ),
          ),
          label: '',
        ),
      ],
      selectedIndex: 2, // Diary tab
    );
  }
}
