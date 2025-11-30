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
import 'package:se501_plantheon/presentation/bloc/activities/activities_event.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_state.dart';
import 'package:se501_plantheon/data/models/activities_models.dart';
import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_event.dart';
import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_state.dart';
import 'package:se501_plantheon/domain/entities/keyword_activity_entity.dart';

enum ActivityType { chiTieu, banSanPham, kyThuat, dichBenh, kinhKhi, khac }

class Activity {
  final String title;
  final String description;
  final ActivityType type;
  final DateTime suggestedTime;
  final DateTime endTime;
  final KeywordActivityEntity originalEntity;

  Activity({
    required this.title,
    required this.description,
    required this.type,
    required this.suggestedTime,
    required this.endTime,
    required this.originalEntity,
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
              description: keywordActivity.description,
              type: _mapTypeToActivityType(keywordActivity.type),
              suggestedTime: _calculateStartTime(keywordActivity),
              endTime: _calculateEndTime(keywordActivity),
              originalEntity: keywordActivity,
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

class _ActivitySuggestionItem extends StatefulWidget {
  final Activity activity;

  const _ActivitySuggestionItem({required this.activity});

  @override
  State<_ActivitySuggestionItem> createState() =>
      _ActivitySuggestionItemState();
}

class _ActivitySuggestionItemState extends State<_ActivitySuggestionItem> {
  // Store edited data
  String? _editedTitle;
  String? _editedDescription;
  String? _editedStartTime;
  String? _editedEndTime;
  bool? _editedIsAllDay;
  String? _editedAlertTime;
  String? _editedRepeat;
  DateTime? _editedEndRepeatDay;
  String? _editedNote;
  Map<String, dynamic>? _draftData;

  // Get current data (edited or original)
  String get currentTitle => _editedTitle ?? widget.activity.title;
  String get currentDescription =>
      _editedDescription ?? widget.activity.description;
  String get currentStartTime =>
      _editedStartTime ??
      '${widget.activity.suggestedTime.hour.toString().padLeft(2, '0')}:${widget.activity.suggestedTime.minute.toString().padLeft(2, '0')}';
  String get currentEndTime =>
      _editedEndTime ??
      '${widget.activity.endTime.hour.toString().padLeft(2, '0')}:${widget.activity.endTime.minute.toString().padLeft(2, '0')}';

  // New getters
  bool get currentIsAllDay => _editedIsAllDay ?? false;
  String get currentAlertTime => _editedAlertTime ?? '';
  String get currentRepeat => _editedRepeat ?? 'Không';
  DateTime? get currentEndRepeatDay => _editedEndRepeatDay;
  String get currentNote => _editedNote ?? '';

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

  void _handleBottomSheetData(Map<String, dynamic> data) {
    if (!mounted) return;

    setState(() {
      _editedTitle = data['title'] as String?;
      _editedDescription = data['description'] as String?;
      _editedStartTime = data['startTime'] as String?;
      _editedEndTime = data['endTime'] as String?;
      _editedIsAllDay = data['isAllDay'] as bool?;
      _editedAlertTime = data['alertTime'] as String?;
      _editedRepeat = data['repeat'] as String?;
      _editedEndRepeatDay = data['endRepeatDay'] as DateTime?;
      _editedNote = data['note'] as String?;

      final formData = data['formData'];
      if (formData is Map<String, dynamic>) {
        _draftData = Map<String, dynamic>.from(formData);
      } else {
        _draftData = null;
      }
    });
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
              initialDate: widget.activity.suggestedTime,
              initialTitle: currentTitle,
              initialDescription: currentDescription,
              initialStartTime: currentStartTime,
              initialEndTime: currentEndTime,
              initialNote: currentNote,
              initialFormData: _draftData == null
                  ? null
                  : Map<String, dynamic>.from(_draftData!),
              onClose: (data) {
                _handleBottomSheetData(data);
              },
            );
            break;
          case ActivityType.banSanPham:
            screen = banSanPhamWidget(
              bloc: activitiesBloc,
              initialDate: widget.activity.suggestedTime,
              initialTitle: currentTitle,
              initialDescription: currentDescription,
              initialStartTime: currentStartTime,
              initialEndTime: currentEndTime,
              initialNote: currentNote,
              initialFormData: _draftData == null
                  ? null
                  : Map<String, dynamic>.from(_draftData!),
              onClose: (data) {
                _handleBottomSheetData(data);
              },
            );
            break;
          case ActivityType.kyThuat:
            screen = kyThuatWidget(
              bloc: activitiesBloc,
              initialDate: widget.activity.suggestedTime,
              initialTitle: currentTitle,
              initialDescription: currentDescription,
              initialStartTime: currentStartTime,
              initialEndTime: currentEndTime,
              initialNote: currentNote,
              initialFormData: _draftData == null
                  ? null
                  : Map<String, dynamic>.from(_draftData!),
              onClose: (data) {
                _handleBottomSheetData(data);
              },
            );
            break;
          case ActivityType.dichBenh:
            screen = dichBenhWidget(
              bloc: activitiesBloc,
              initialDate: widget.activity.suggestedTime,
              initialTitle: currentTitle,
              initialDescription: currentDescription,
              initialStartTime: currentStartTime,
              initialEndTime: currentEndTime,
              initialNote: currentNote,
              initialFormData: _draftData == null
                  ? null
                  : Map<String, dynamic>.from(_draftData!),
              onClose: (data) {
                _handleBottomSheetData(data);
              },
            );
            break;
          case ActivityType.kinhKhi:
            screen = climaMateWidget(
              bloc: activitiesBloc,
              initialDate: widget.activity.suggestedTime,
              initialTitle: currentTitle,
              initialDescription: currentDescription,
              initialStartTime: currentStartTime,
              initialEndTime: currentEndTime,
              initialIsAllDay: currentIsAllDay,
              initialAlertTime: currentAlertTime,
              initialRepeat: currentRepeat,
              initialEndRepeatDay: currentEndRepeatDay,
              initialNote: currentNote,
              initialFormData: _draftData == null
                  ? null
                  : Map<String, dynamic>.from(_draftData!),
              onClose: (data) {
                _handleBottomSheetData(data);
              },
            );
            break;
          case ActivityType.khac:
            screen = otherWidget(
              bloc: activitiesBloc,
              initialDate: widget.activity.suggestedTime,
              initialTitle: currentTitle,
              initialDescription: currentDescription,
              initialStartTime: currentStartTime,
              initialEndTime: currentEndTime,
              initialNote: currentNote,
              initialFormData: _draftData == null
                  ? null
                  : Map<String, dynamic>.from(_draftData!),
              onClose: (data) {
                _handleBottomSheetData(data);
              },
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
                              onPressed: () {
                                // Save edited data when closing
                                // We'll get this data from the form controllers
                                // For now, we need to add a way to get data back from the form
                                Navigator.of(sheetContext).pop();
                              },
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
    ).then((result) {
      if (result is Map<String, dynamic>) {
        _handleBottomSheetData(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = ActivityTypeConfig.getConfig(widget.activity.type);

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
                    currentTitle,
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
                          _getTypeString(widget.activity.type),
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
                          '$currentStartTime - $currentEndTime, ${DateFormat('dd/MM/yyyy').format(widget.activity.suggestedTime)}',
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
                    onPressed: () =>
                        _openBottomSheet(context, widget.activity.type),
                  ),
                ),
                const SizedBox(width: 8),
                _AddButton(
                  accentColor: config.accentColor,
                  activity: widget.activity,
                  bloc: context.read<ActivitiesBloc>(),
                  editedTitle: _editedTitle,
                  editedDescription: _editedDescription,
                  editedStartTime: _editedStartTime,
                  editedEndTime: _editedEndTime,
                  editedIsAllDay: _editedIsAllDay,
                  editedAlertTime: _editedAlertTime,
                  editedRepeat: _editedRepeat,
                  editedEndRepeatDay: _editedEndRepeatDay,
                  editedNote: _editedNote,
                ),
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
  final Activity activity;
  final ActivitiesBloc bloc;
  final String? editedTitle;
  final String? editedDescription;
  final String? editedStartTime;
  final String? editedEndTime;
  final bool? editedIsAllDay;
  final String? editedAlertTime;
  final String? editedRepeat;
  final DateTime? editedEndRepeatDay;
  final String? editedNote;

  const _AddButton({
    required this.accentColor,
    required this.activity,
    required this.bloc,
    this.editedTitle,
    this.editedDescription,
    this.editedStartTime,
    this.editedEndTime,
    this.editedIsAllDay,
    this.editedAlertTime,
    this.editedRepeat,
    this.editedEndRepeatDay,
    this.editedNote,
  });

  @override
  __AddButtonState createState() => __AddButtonState();
}

class __AddButtonState extends State<_AddButton> {
  bool _isAdded = false;
  bool _isLoading = false;
  String? _createdActivityId;
  late String _correlationId;

  @override
  void initState() {
    super.initState();
    // Use the original entity ID as the correlation ID for this button
    _correlationId = widget.activity.originalEntity.id;
  }

  String _getActivityTypeString(ActivityType type) {
    switch (type) {
      case ActivityType.chiTieu:
        return 'EXPENSE';
      case ActivityType.banSanPham:
        return 'INCOME';
      case ActivityType.kyThuat:
        return 'TECHNIQUE';
      case ActivityType.dichBenh:
        return 'DISEASE';
      case ActivityType.kinhKhi:
        return 'CLIMATE';
      case ActivityType.khac:
        return 'OTHER';
    }
  }

  String _formatToISO8601(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '$year-$month-${day}T$hour:$minute:${second}Z';
  }

  void _createActivity() {
    if (_isAdded || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Use edited data if available, otherwise use original suggestion data
      final title = widget.editedTitle ?? widget.activity.title;
      final description =
          widget.editedDescription ?? widget.activity.description;
      final isAllDay = widget.editedIsAllDay ?? false;
      final alertTime = widget.editedAlertTime;
      final repeat = widget.editedRepeat ?? 'Không';
      final endRepeatDay = widget.editedEndRepeatDay;
      final note = widget.editedNote;

      // Parse times to create DateTime objects
      final startTime =
          widget.editedStartTime ??
          '${widget.activity.suggestedTime.hour.toString().padLeft(2, '0')}:${widget.activity.suggestedTime.minute.toString().padLeft(2, '0')}';
      final endTime =
          widget.editedEndTime ??
          '${widget.activity.endTime.hour.toString().padLeft(2, '0')}:${widget.activity.endTime.minute.toString().padLeft(2, '0')}';

      // Parse time strings
      final startTimeParts = startTime.split(':');
      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);

      final endTimeParts = endTime.split(':');
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);

      // Create DateTime with edited times
      final startDateTime = DateTime(
        widget.activity.suggestedTime.year,
        widget.activity.suggestedTime.month,
        widget.activity.suggestedTime.day,
        startHour,
        startMinute,
      );

      final endDateTime = DateTime(
        widget.activity.endTime.year,
        widget.activity.endTime.month,
        widget.activity.endTime.day,
        endHour,
        endMinute,
      );

      final request = CreateActivityRequestModel(
        title: title,
        type: _getActivityTypeString(widget.activity.type),
        day: isAllDay,
        timeStart: _formatToISO8601(startDateTime),
        timeEnd: _formatToISO8601(endDateTime),
        repeat: repeat,
        isRepeat: repeat != 'Không' ? 'True' : 'False',
        endRepeatDay: endRepeatDay != null
            ? _formatToISO8601(endRepeatDay)
            : null,
        description: description.isNotEmpty ? description : null,
        note: note,
        alertTime: alertTime,
        attachedLink: '',
      );

      widget.bloc.add(
        CreateActivityEvent(request: request, correlationId: _correlationId),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo hoạt động: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteActivity() {
    if (!_isAdded || _isLoading || _createdActivityId == null) return;

    setState(() {
      _isLoading = true;
    });

    widget.bloc.add(
      DeleteActivityEvent(
        id: _createdActivityId!,
        correlationId: _correlationId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivitiesBloc, ActivitiesState>(
      bloc: widget.bloc,
      listener: (context, state) {
        if (state is CreateActivitySuccess) {
          if (state.correlationId == _correlationId) {
            if (mounted) {
              setState(() {
                _isAdded = true;
                _isLoading = false;
                _createdActivityId = state.response.id;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã tạo hoạt động thành công!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        } else if (state is CreateActivityError) {
          if (state.correlationId == _correlationId) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi tạo hoạt động: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else if (state is DeleteActivitySuccess) {
          if (state.correlationId == _correlationId) {
            if (mounted) {
              setState(() {
                _isAdded = false;
                _isLoading = false;
                _createdActivityId = null;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa hoạt động thành công!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        } else if (state is DeleteActivityError) {
          if (state.correlationId == _correlationId) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi xóa hoạt động: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: widget.accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.accentColor,
                    ),
                  ),
                )
              : _isAdded
              ? Icon(Icons.check_circle, color: widget.accentColor, size: 20)
              : Icon(
                  Icons.add_circle_outline,
                  color: widget.accentColor,
                  size: 20,
                ),
          onPressed: _isLoading
              ? null
              : (_isAdded ? _deleteActivity : _createActivity),
        ),
      ),
    );
  }
}
