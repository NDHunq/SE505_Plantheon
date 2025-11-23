import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:se501_plantheon/presentation/screens/diary/chiTieu.dart';
import 'package:se501_plantheon/presentation/screens/diary/banSanPham.dart';
import 'package:se501_plantheon/presentation/screens/diary/other.dart';
import 'package:se501_plantheon/presentation/screens/diary/kyThuat.dart';
import 'package:se501_plantheon/presentation/screens/diary/dichBenh.dart';
import 'package:se501_plantheon/presentation/screens/diary/climamate.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_event.dart';
import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_state.dart';
import 'package:se501_plantheon/domain/entities/keyword_activity_entity.dart';

enum ActivityType { chiTieu, banSanPham, kyThuat, dichBenh, kinhKhi, khac }

class Activity {
  final String title;
  final ActivityType type;
  final DateTime suggestedTime;
  final DateTime endTime;

  Activity({
    required this.title,
    required this.type,
    required this.suggestedTime,
    required this.endTime,
  });
}

class ActivityTypeConfig {
  final Color backgroundColor;
  final Color accentColor;
  final IconData icon;

  ActivityTypeConfig({
    required this.backgroundColor,
    required this.accentColor,
    required this.icon,
  });

  static ActivityTypeConfig getConfig(ActivityType type) {
    switch (type) {
      case ActivityType.chiTieu:
        return ActivityTypeConfig(
          backgroundColor: const Color(0xFFFFF3E0),
          accentColor: const Color(0xFFFF9800),
          icon: Icons.attach_money_rounded,
        );
      case ActivityType.banSanPham:
        return ActivityTypeConfig(
          backgroundColor: const Color(0xFFE8F5E9),
          accentColor: const Color(0xFF4CAF50),
          icon: Icons.shopping_cart_rounded,
        );
      case ActivityType.kyThuat:
        return ActivityTypeConfig(
          backgroundColor: const Color(0xFFEDE7F6),
          accentColor: const Color(0xFF673AB7),
          icon: Icons.engineering_rounded,
        );
      case ActivityType.dichBenh:
        return ActivityTypeConfig(
          backgroundColor: const Color(0xFFFFEBEE),
          accentColor: const Color(0xFFE53935),
          icon: Icons.coronavirus_rounded,
        );
      case ActivityType.kinhKhi:
        return ActivityTypeConfig(
          backgroundColor: const Color(0xFFE1F5FE),
          accentColor: const Color(0xFF0288D1),
          icon: Icons.cloud_rounded,
        );
      case ActivityType.khac:
        return ActivityTypeConfig(
          backgroundColor: const Color(0xFFE3F2FD),
          accentColor: const Color(0xFF2196F3),
          icon: Icons.more_horiz_rounded,
        );
    }
  }
}

class ActivitiesSuggestionList extends StatelessWidget {
  final String diseaseId;

  const ActivitiesSuggestionList({
    super.key,
    this.diseaseId = '006c9e8c-2f71-4608-9134-6b9f3ff9c1e1',
  });

  ActivityType _mapTypeToActivityType(String type) {
    switch (type.toUpperCase()) {
      case 'EXPENSE':
        return ActivityType.chiTieu;
      case 'INCOME':
        return ActivityType.banSanPham;
      case 'TECHNIQUE':
        return ActivityType.kyThuat;
      case 'DISEASE':
        return ActivityType.dichBenh;
      case 'CLIMATE':
        return ActivityType.kinhKhi;
      case 'OTHER':
      default:
        return ActivityType.khac;
    }
  }

  DateTime _calculateStartTime(KeywordActivityEntity keywordActivity) {
    final now = DateTime.now();
    final baseDate = now.add(Duration(days: keywordActivity.baseDaysOffset));

    // Luôn dùng hour_time từ database
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      keywordActivity.hourTime,
      0,
    );
  }

  DateTime _calculateEndTime(KeywordActivityEntity keywordActivity) {
    final now = DateTime.now();
    final baseDate = now.add(Duration(days: keywordActivity.baseDaysOffset));

    // Luôn dùng end_hour_time từ database
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      keywordActivity.endHourTime,
      0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KeywordActivitiesBloc, KeywordActivitiesState>(
      builder: (context, state) {
        if (state is KeywordActivitiesLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is KeywordActivitiesError) {
          // Check if it's a 404 error
          final is404 = state.message.contains('404');

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    is404 ? Icons.cloud_off_outlined : Icons.error_outline,
                    size: 48,
                    color: is404 ? Colors.orange : Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    is404 ? 'API chưa sẵn sàng' : 'Lỗi khi tải dữ liệu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: is404 ? Colors.orange : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    is404
                        ? 'Endpoint /keyword-activities/disease/{id}\nchưa được triển khai trên backend'
                        : state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<KeywordActivitiesBloc>().add(
                        FetchKeywordActivities(diseaseId: diseaseId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is KeywordActivitiesLoaded) {
          if (state.activities.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Không có hoạt động gợi ý',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          final activities = state.activities.map((keywordActivity) {
            return Activity(
              title: keywordActivity.name,
              type: _mapTypeToActivityType(keywordActivity.type),
              suggestedTime: _calculateStartTime(keywordActivity),
              endTime: _calculateEndTime(keywordActivity),
            );
          }).toList();

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return _ActivitySuggestionItem(activity: activities[index]);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          );
        }

        // Initial state
        return const SizedBox.shrink();
      },
    );
  }
}

class _ActivitySuggestionItem extends StatelessWidget {
  final Activity activity;

  const _ActivitySuggestionItem({required this.activity});

  String _getTypeString(ActivityType type) {
    switch (type) {
      case ActivityType.chiTieu:
        return 'Chi Tiêu';
      case ActivityType.banSanPham:
        return 'Bán sản phẩm';
      case ActivityType.kyThuat:
        return 'Kỹ thuật';
      case ActivityType.dichBenh:
        return 'Dịch bệnh';
      case ActivityType.kinhKhi:
        return 'Khí hậu';
      case ActivityType.khac:
        return 'Khác';
    }
  }

  String _getSheetTitle(ActivityType type) {
    switch (type) {
      case ActivityType.chiTieu:
        return 'Chi tiêu';
      case ActivityType.banSanPham:
        return 'Bán sản phẩm';
      case ActivityType.kyThuat:
        return 'Kỹ thuật';
      case ActivityType.dichBenh:
        return 'Dịch bệnh';
      case ActivityType.kinhKhi:
        return 'Khí hậu';
      case ActivityType.khac:
        return 'Hoạt động khác';
    }
  }

  void _openBottomSheet(BuildContext context, ActivityType type) {
    final activitiesBloc = context.read<ActivitiesBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        Widget screen;
        switch (type) {
          case ActivityType.chiTieu:
            screen = chiTieuWidget(
              bloc: activitiesBloc,
              initialDate: activity.suggestedTime,
            );
            break;
          case ActivityType.banSanPham:
            screen = banSanPhamWidget(
              bloc: activitiesBloc,
              initialDate: activity.suggestedTime,
            );
            break;
          case ActivityType.kyThuat:
            screen = kyThuatWidget(
              bloc: activitiesBloc,
              initialDate: activity.suggestedTime,
            );
            break;
          case ActivityType.dichBenh:
            screen = dichBenhWidget(
              bloc: activitiesBloc,
              initialDate: activity.suggestedTime,
            );
            break;
          case ActivityType.kinhKhi:
            screen = climaMateWidget(
              bloc: activitiesBloc,
              initialDate: activity.suggestedTime,
            );
            break;
          case ActivityType.khac:
            screen = otherWidget(
              bloc: activitiesBloc,
              initialDate: activity.suggestedTime,
            );
            break;
        }

        final mediaQuery = MediaQuery.of(sheetContext);
        final bottomInset = mediaQuery.viewInsets.bottom;
        final title = _getSheetTitle(type);

        return BlocProvider.value(
          value: activitiesBloc,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  height: mediaQuery.size.height * 0.92,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.of(sheetContext).pop(),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: screen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ActivityTypeConfig.getConfig(activity.type);

    return Container(
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: config.accentColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: config.accentColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon bên trái
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: config.accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(config.icon, color: config.accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            // Nội dung chính
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Type và ngày giờ trên 1 hàng
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: config.accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getTypeString(activity.type),
                          style: TextStyle(
                            color: config.accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${DateFormat.Hm().format(activity.suggestedTime)} - ${DateFormat.Hm().format(activity.endTime)}, ${DateFormat('dd/MM/yyyy').format(activity.suggestedTime)}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 2 nút bên phải trên 1 hàng
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: config.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.edit_outlined,
                      color: config.accentColor,
                      size: 20,
                    ),
                    onPressed: () => _openBottomSheet(context, activity.type),
                  ),
                ),
                const SizedBox(width: 8),
                _AddButton(accentColor: config.accentColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  final Color accentColor;

  const _AddButton({required this.accentColor});

  @override
  __AddButtonState createState() => __AddButtonState();
}

class __AddButtonState extends State<_AddButton> {
  bool _isAdded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: widget.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: _isAdded
            ? Icon(Icons.check_circle, color: widget.accentColor, size: 20)
            : Icon(
                Icons.add_circle_outline,
                color: widget.accentColor,
                size: 20,
              ),
        onPressed: () {
          setState(() {
            _isAdded = !_isAdded;
          });
        },
      ),
    );
  }
}
