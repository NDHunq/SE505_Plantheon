import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_event.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_state.dart';
import 'package:se501_plantheon/presentation/screens/scan/models/activity_ui_model.dart';
import 'package:se501_plantheon/data/models/activities_models.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/presentation/screens/diary/chiTieu.dart';
import 'package:se501_plantheon/presentation/screens/diary/banSanPham.dart';
import 'package:se501_plantheon/presentation/screens/diary/other.dart';
import 'package:se501_plantheon/presentation/screens/diary/kyThuat.dart';
import 'package:se501_plantheon/presentation/screens/diary/dichBenh.dart';
import 'package:se501_plantheon/presentation/screens/diary/climamate.dart';
import 'package:toastification/toastification.dart';

class ReusableActivitySuggestionItem extends StatefulWidget {
  final Activity activity;

  const ReusableActivitySuggestionItem({super.key, required this.activity});

  @override
  State<ReusableActivitySuggestionItem> createState() =>
      _ReusableActivitySuggestionItemState();
}

class _ReusableActivitySuggestionItemState
    extends State<ReusableActivitySuggestionItem> {
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
                ReusableAddButton(
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

class ReusableAddButton extends StatefulWidget {
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

  const ReusableAddButton({
    super.key,
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
  _ReusableAddButtonState createState() => _ReusableAddButtonState();
}

class _ReusableAddButtonState extends State<ReusableAddButton> {
  bool _isAdded = false;
  bool _isLoading = false;
  late String _correlationId;
  String? _createdActivityId;

  @override
  void initState() {
    super.initState();
    // Use current timestamp as correlationId if original ID is placeholder
    // or just generate a unique one if not present, but for now reuse activity logic
    _correlationId = widget.activity.originalEntity.id.isNotEmpty
        ? widget.activity.originalEntity.id
        : DateTime.now().millisecondsSinceEpoch.toString();
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

  String _formatDateTimeToISO8601(DateTime dateTime) {
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
      final title = widget.editedTitle ?? widget.activity.title;
      final description =
          widget.editedDescription ?? widget.activity.description;
      final isAllDay = widget.editedIsAllDay ?? false;
      final alertTime = widget.editedAlertTime;
      final repeat = widget.editedRepeat ?? 'NONE';
      final endRepeatDay = widget.editedEndRepeatDay;
      final note = widget.editedNote ?? '';

      final startTime =
          widget.editedStartTime ??
          '${widget.activity.suggestedTime.hour.toString().padLeft(2, '0')}:${widget.activity.suggestedTime.minute.toString().padLeft(2, '0')}';
      final endTime =
          widget.editedEndTime ??
          '${widget.activity.endTime.hour.toString().padLeft(2, '0')}:${widget.activity.endTime.minute.toString().padLeft(2, '0')}';

      final startTimeParts = startTime.split(':');
      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);

      final endTimeParts = endTime.split(':');
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);

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

      // Create base request from edited data
      final request = CreateActivityRequestModel(
        title: title,
        description: description,
        type: _getActivityTypeString(widget.activity.type),
        timeStart: _formatDateTimeToISO8601(startDateTime),
        timeEnd: _formatDateTimeToISO8601(endDateTime),
        day: isAllDay,
        alertTime: alertTime,
        repeat: repeat,
        endRepeatDay: endRepeatDay != null
            ? _formatDateTimeToISO8601(endRepeatDay)
            : null,
        note: note,
      );

      print('🚀 AddButton: Creating activity: $title');
      print('   Time: $startTime - $endTime');

      context.read<ActivitiesBloc>().add(
        CreateActivityEvent(request: request, correlationId: _correlationId),
      );
    } catch (e) {
      print('❌ Error preparing activity data: $e');
      setState(() {
        _isLoading = false;
      });
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: Text('Lỗi khi chuẩn bị dữ liệu: $e'),
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.bottomCenter,
        showProgressBar: true,
      );
    }
  }

  void _deleteActivity() {
    if (!_isAdded || _isLoading || _createdActivityId == null) return;

    setState(() {
      _isLoading = true;
    });

    context.read<ActivitiesBloc>().add(
      DeleteActivityEvent(
        id: _createdActivityId!,
        correlationId: _correlationId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivitiesBloc, ActivitiesState>(
      listener: (context, state) {
        if (state is CreateActivitySuccess) {
          if (state.correlationId == _correlationId) {
            if (mounted) {
              setState(() {
                _isAdded = true;
                _isLoading = false;
                _createdActivityId = state.response.id;
              });

              toastification.show(
                context: context,
                type: ToastificationType.success,
                style: ToastificationStyle.flat,
                title: const Text('Đã thêm hoạt động vào nhật ký!'),
                autoCloseDuration: const Duration(seconds: 2),
                alignment: Alignment.bottomCenter,
                showProgressBar: true,
                icon: const Icon(Icons.check_circle, color: Colors.green),
              );
            }
          }
        } else if (state is CreateActivityError) {
          if (state.correlationId == _correlationId) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              toastification.show(
                context: context,
                type: ToastificationType.error,
                style: ToastificationStyle.flat,
                title: Text('Lỗi tạo hoạt động: ${state.message}'),
                autoCloseDuration: const Duration(seconds: 3),
                alignment: Alignment.bottomCenter,
                showProgressBar: true,
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

              toastification.show(
                context: context,
                type: ToastificationType.success,
                style: ToastificationStyle.flat,
                title: const Text('Đã xóa hoạt động thành công!'),
                autoCloseDuration: const Duration(seconds: 2),
                alignment: Alignment.bottomCenter,
                showProgressBar: true,
                icon: const Icon(Icons.check_circle, color: Colors.green),
              );
            }
          }
        } else if (state is DeleteActivityError) {
          if (state.correlationId == _correlationId) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              toastification.show(
                context: context,
                type: ToastificationType.error,
                style: ToastificationStyle.flat,
                title: Text('Lỗi xóa hoạt động: ${state.message}'),
                autoCloseDuration: const Duration(seconds: 3),
                alignment: Alignment.bottomCenter,
                showProgressBar: true,
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
              ? const SizedBox(width: 20, height: 20, child: LoadingIndicator())
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
