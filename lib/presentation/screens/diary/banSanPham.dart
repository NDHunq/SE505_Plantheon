import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:se501_plantheon/common/helpers/dayCompare.dart';
import 'package:se501_plantheon/common/helpers/decimalTextInputFormatter.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/common/widgets/textfield/text_field.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/services/supabase_service.dart';
import 'package:se501_plantheon/core/services/firebase_notification_service.dart';
import 'package:se501_plantheon/presentation/screens/diary/widgets/addNew_Row_1_2.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_event.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_state.dart';
import 'package:se501_plantheon/data/models/activities_models.dart';
import 'package:se501_plantheon/domain/entities/activities_entities.dart';
import 'package:toastification/toastification.dart';

class banSanPhamWidget extends StatefulWidget {
  final DayActivityDetailEntity? activityToEdit;
  final ActivitiesBloc? bloc;
  final DateTime? initialDate;
  final VoidCallback? onSubmitSuccess;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialStartTime;
  final String? initialEndTime;
  final bool? initialIsAllDay;
  final String? initialAlertTime;
  final String? initialRepeat;
  final DateTime? initialEndRepeatDay;
  final String? initialNote;
  final Map<String, dynamic>? initialFormData;
  final Function(Map<String, dynamic>)? onClose;

  const banSanPhamWidget({
    super.key,
    this.activityToEdit,
    this.bloc,
    this.initialDate,
    this.onSubmitSuccess,
    this.initialTitle,
    this.initialDescription,
    this.initialStartTime,
    this.initialEndTime,
    this.initialIsAllDay,
    this.initialAlertTime,
    this.initialRepeat,
    this.initialEndRepeatDay,
    this.initialNote,
    this.initialFormData,
    this.onClose,
  });

  @override
  State<banSanPhamWidget> createState() => _banSanPhamWidgetState();
}

class _banSanPhamWidgetState extends State<banSanPhamWidget> {
  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController purchasedItemController = TextEditingController(
    text: "",
  );
  final TextEditingController quantityController = TextEditingController(
    text: "",
  );
  final TextEditingController amountController = TextEditingController(
    text: "",
  );
  final TextEditingController purposeController = TextEditingController(
    text: "",
  );
  final TextEditingController purchasedForController = TextEditingController(
    text: "",
  );
  final TextEditingController buyerController = TextEditingController(text: "");
  final TextEditingController noteController = TextEditingController(text: "");

  // State variables
  bool allDay = false;
  String startTime = "14:20";
  String endTime = "15:00";
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String repeatType = "Không";
  String endRepeatType = "Không";
  DateTime repeatEndDate = DateTime.now();
  String alertTime = "";
  String category = "";
  String unit = "Kg";
  String currency = "đ";
  String? attachedLink;
  bool _isUploadingImage = false;

  // Danh sách phân loại và đơn vị tính
  List<String> categories = ["A", "B", "C"];
  List<String> units = ["Kg", "Tấn", "Lít", "Mét", "Cái"];
  List<String> currencies = ["đ", "USD", "VND", "EUR"];

  // Notification service
  final FirebaseNotificationService _notificationService =
      FirebaseNotificationService();

  // Validation methods
  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tiêu đề không được để trống';
    }
    return null;
  }

  // Schedule notification based on alertTime
  Future<void> _scheduleNotification() async {
    try {
      if (alertTime == "Không" || alertTime.isEmpty) {
        return;
      }

      DateTime notificationTime;
      final timeParts = startTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      DateTime activityStartTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        hour,
        minute,
      );

      if (alertTime == "Trước 5 phút") {
        notificationTime = activityStartTime.subtract(
          const Duration(minutes: 5),
        );
      } else if (alertTime == "Trước 1 ngày") {
        notificationTime = activityStartTime.subtract(const Duration(days: 1));
      } else {
        return;
      }

      final now = DateTime.now();
      final duration = notificationTime.difference(now);

      if (notificationTime.isBefore(now)) {
        await _notificationService.sendLocalNotification(
          title: '⏰ Nhắc nhở: ${titleController.text}',
          body: 'Hoạt động sắp bắt đầu vào $startTime!',
        );
      } else {
        await _notificationService.scheduleNotificationAfterDelay(
          title: '⏰ Nhắc nhở: ${titleController.text}',
          body: 'Hoạt động sắp bắt đầu vào $startTime!',
          delay: duration,
        );

        await _notificationService.sendLocalNotification(
          title: '✅ Đã đặt nhắc nhở',
          body:
              'Bạn sẽ nhận được thông báo ${alertTime.toLowerCase()} cho: ${titleController.text}',
        );
      }
    } catch (e) {
      // Error scheduling notification
    }
  }

  @override
  void initState() {
    super.initState();

    // Nếu đang edit, fill data vào form
    if (widget.activityToEdit != null) {
      final activity = widget.activityToEdit!;

      // Basic fields
      titleController.text = activity.title;
      allDay = activity.day;

      // Parse time from DateTime
      final startLocal = activity.timeStart.toLocal();
      final endLocal = activity.timeEnd.toLocal();
      startDate = startLocal;
      endDate = endLocal;
      startTime =
          '${startLocal.hour.toString().padLeft(2, '0')}:${startLocal.minute.toString().padLeft(2, '0')}';
      endTime =
          '${endLocal.hour.toString().padLeft(2, '0')}:${endLocal.minute.toString().padLeft(2, '0')}';

      // Fill additional fields
      if (activity.repeat != null && activity.repeat!.isNotEmpty) {
        repeatType = activity.repeat!;
      } else {
        repeatType = "Không";
      }
      if (activity.isRepeat != null && activity.isRepeat!.isNotEmpty) {
        endRepeatType = activity.isRepeat!;
      } else {
        endRepeatType = "Không";
      }
      if (activity.endRepeatDay != null) {
        repeatEndDate = activity.endRepeatDay!;
      }
      if (activity.object != null) {
        purchasedItemController.text = activity.object!;
      }
      if (activity.unit != null) {
        unit = activity.unit!;
      }
      if (activity.amount != null) {
        quantityController.text = activity.amount!.toString();
      }
      if (activity.targetPerson != null) {
        purchasedForController.text = activity.targetPerson!;
      }
      if (activity.sourcePerson != null) {
        buyerController.text = activity.sourcePerson!;
      }
      if (activity.note != null) {
        noteController.text = activity.note!;
      }
      if (activity.money != null) {
        amountController.text = activity.money!.toString();
      }
      if (activity.purpose != null) {
        purposeController.text = activity.purpose!;
      }
      // Load attached image link
      if (activity.attachedLink != null && activity.attachedLink!.isNotEmpty) {
        attachedLink = activity.attachedLink;
      }
    } else {
      // Nếu tạo mới, thiết lập ngày và thời gian mặc định
      _initializeDefaultDateTime();

      // Pre-fill từ suggestion nếu có
      if (widget.initialTitle != null) {
        titleController.text = widget.initialTitle!;
      }
      if (widget.initialDescription != null) {
        noteController.text = widget.initialDescription!;
      }
      if (widget.initialStartTime != null) {
        startTime = widget.initialStartTime!;
      }
      if (widget.initialEndTime != null) {
        endTime = widget.initialEndTime!;
      }
      if (widget.initialIsAllDay != null) {
        allDay = widget.initialIsAllDay!;
      }
      if (widget.initialAlertTime != null) {
        alertTime = widget.initialAlertTime!;
      }
      if (widget.initialRepeat != null) {
        repeatType = widget.initialRepeat!;
      }
      if (widget.initialEndRepeatDay != null) {
        repeatEndDate = widget.initialEndRepeatDay!;
      }
    }

    _applyInitialFormData();
  }

  void _initializeDefaultDateTime() {
    final DateTime now = DateTime.now();
    final DateTime targetDate = widget.initialDate ?? now;

    // Thiết lập ngày
    startDate = targetDate;
    endDate = targetDate;

    // Kiểm tra xem có phải ngày hôm nay không
    final bool isToday =
        targetDate.year == now.year &&
        targetDate.month == now.month &&
        targetDate.day == now.day;

    if (isToday) {
      // Ngày hôm nay: giờ bắt đầu = giờ hiện tại, giờ kết thúc = giờ hiện tại + 1h
      final DateTime startDateTime = now;
      final DateTime endDateTime = now.add(const Duration(hours: 1));

      startTime =
          '${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}';
      endTime =
          '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Ngày khác: 6:00 - 7:00
      startTime = "06:00";
      endTime = "07:00";
    }
  }

  void _applyInitialFormData() {
    if (widget.activityToEdit != null) return;
    final data = widget.initialFormData;
    if (data == null || data.isEmpty) return;

    void setTextController(TextEditingController controller, String key) {
      final value = data[key];
      if (value is String) {
        controller.text = value;
      }
    }

    setTextController(titleController, 'title');
    setTextController(noteController, 'note');
    setTextController(noteController, 'description');
    setTextController(purchasedItemController, 'purchasedItem');
    setTextController(quantityController, 'quantity');
    setTextController(amountController, 'amount');
    setTextController(purposeController, 'purpose');
    setTextController(purchasedForController, 'purchasedFor');
    setTextController(buyerController, 'buyer');

    final startTimeValue = data['startTime'];
    if (startTimeValue is String && startTimeValue.isNotEmpty) {
      startTime = startTimeValue;
    }
    final endTimeValue = data['endTime'];
    if (endTimeValue is String && endTimeValue.isNotEmpty) {
      endTime = endTimeValue;
    }

    final startDateValue = data['startDate'];
    if (startDateValue is DateTime) {
      startDate = startDateValue;
    }
    final endDateValue = data['endDate'];
    if (endDateValue is DateTime) {
      endDate = endDateValue;
    }

    final allDayValue = data['isAllDay'];
    if (allDayValue is bool) {
      allDay = allDayValue;
    }

    final repeatValue = data['repeat'];
    if (repeatValue is String) {
      repeatType = repeatValue;
    }

    final endRepeatTypeValue = data['endRepeatType'];
    if (endRepeatTypeValue is String) {
      endRepeatType = endRepeatTypeValue;
    }

    final endRepeatDayValue = data['endRepeatDay'];
    if (endRepeatDayValue is DateTime) {
      repeatEndDate = endRepeatDayValue;
    }

    final alertValue = data['alertTime'];
    if (alertValue is String) {
      alertTime = alertValue;
    }

    final unitValue = data['unit'];
    if (unitValue is String && unitValue.isNotEmpty) {
      unit = unitValue;
    }

    final currencyValue = data['currency'];
    if (currencyValue is String && currencyValue.isNotEmpty) {
      currency = currencyValue;
    }

    final categoryValue = data['category'];
    if (categoryValue is String) {
      category = categoryValue;
    }

    final attachedLinkValue = data['attachedLink'];
    if (attachedLinkValue is String) {
      attachedLink = attachedLinkValue;
    }
  }

  Map<String, dynamic> _buildFormData() {
    return {
      'title': titleController.text,
      'description': noteController.text,
      'note': noteController.text,
      'purchasedItem': purchasedItemController.text,
      'quantity': quantityController.text,
      'amount': amountController.text,
      'purpose': purposeController.text,
      'purchasedFor': purchasedForController.text,
      'buyer': buyerController.text,
      'isAllDay': allDay,
      'startTime': startTime,
      'endTime': endTime,
      'startDate': startDate,
      'endDate': endDate,
      'repeat': repeatType,
      'endRepeatType': endRepeatType,
      'endRepeatDay': repeatEndDate,
      'alertTime': alertTime,
      'unit': unit,
      'currency': currency,
      'category': category,
      'attachedLink': attachedLink,
    };
  }

  @override
  void dispose() {
    titleController.dispose();
    purchasedItemController.dispose();
    quantityController.dispose();
    amountController.dispose();
    purposeController.dispose();
    purchasedForController.dispose();
    buyerController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // Phương thức chọn thời gian bắt đầu
  Future<void> _selectStartTime(BuildContext context) async {
    // Parse thời gian hiện tại từ startTime string
    final timeParts = startTime.split(':');
    final currentHour = int.parse(timeParts[0]);
    final currentMinute = int.parse(timeParts[1]);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        startTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  // Phương thức chọn thời gian kết thúc
  Future<void> _selectEndTime(BuildContext context) async {
    // Parse thời gian hiện tại từ endTime string
    final timeParts = endTime.split(':');
    final currentHour = int.parse(timeParts[0]);
    final currentMinute = int.parse(timeParts[1]);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        endTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  // Phương thức chọn ngày bắt đầu
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  // Phương thức chọn ngày kết thúc
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  // Phương thức hiển thị dialog chọn lặp lại
  Future<void> _showRepeatDialog(BuildContext context) async {
    final List<String> repeatOptions = [
      "Không",
      "Hàng ngày",
      "Hàng tuần",
      "Hàng tháng",
      "Hàng năm",
    ];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Chọn lặp lại"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: repeatOptions.map((option) {
              return ListTile(
                title: Text(option),
                onTap: () {
                  setState(() {
                    repeatType = option;
                  });
                  Navigator.of(context).pop();
                },
                trailing: repeatType == option
                    ? const Icon(Icons.check, color: AppColors.primary_600)
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Phương thức hiển thị dialog chọn kết thúc lặp lại
  Future<void> _showEndRepeatDialog(BuildContext context) async {
    final List<String> endRepeatOptions = ["Không", "Ngày"];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Kết thúc lặp lại"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: endRepeatOptions.map((option) {
              return ListTile(
                title: Text(option),
                onTap: () {
                  setState(() {
                    endRepeatType = option;
                  });
                  Navigator.of(context).pop();
                },
                trailing: endRepeatType == option
                    ? const Icon(Icons.check, color: AppColors.primary_600)
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Phương thức chọn ngày kết thúc lặp lại
  Future<void> _selectRepeatEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: repeatEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        repeatEndDate = picked;
      });
    }
  }

  // Phương thức upload ảnh
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = '${timestamp}_${image.name}';

        final url = await SupabaseService.uploadFileFromBytes(
          bucketName: 'uploads',
          fileBytes: bytes,
          fileName: fileName,
        );

        setState(() {
          attachedLink = url;
          _isUploadingImage = false;
        });

        if (mounted) {
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            title: Text('✓ Upload ảnh thành công!'),
            autoCloseDuration: const Duration(seconds: 2),
            alignment: Alignment.bottomCenter,
            showProgressBar: true,
          );
        }
      } else {
        setState(() {
          _isUploadingImage = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          title: Text('Lỗi upload ảnh: $e'),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.bottomCenter,
          showProgressBar: true,
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn nguồn ảnh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary_600,
              ),
              title: const Text('Thư viện ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.primary_600,
              ),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Phương thức hiển thị dialog chọn cảnh báo
  Future<void> _showAlertDialog(BuildContext context) async {
    final List<String> alertOptions = ["Không", "Trước 5 phút", "Trước 1 ngày"];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Chọn cảnh báo"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: alertOptions.map((option) {
              return ListTile(
                title: Text(option),
                onTap: () {
                  setState(() {
                    alertTime = option;
                  });
                  Navigator.of(context).pop();
                },
                trailing: alertTime == option
                    ? const Icon(Icons.check, color: AppColors.primary_600)
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Phương thức hiển thị dialog chọn đơn vị tính
  Future<void> _showUnitDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Chọn đơn vị tính"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: units.map((unitItem) {
              return ListTile(
                title: Text(unitItem),
                onTap: () {
                  setState(() {
                    unit = unitItem;
                  });
                  Navigator.of(context).pop();
                },
                trailing: unit == unitItem
                    ? const Icon(Icons.check, color: AppColors.primary_600)
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Phương thức hiển thị dialog chọn đơn vị tiền tệ
  Future<void> _showCurrencyDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Chọn đơn vị tiền tệ"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: currencies.map((currencyItem) {
              return ListTile(
                title: Text(currencyItem),
                onTap: () {
                  setState(() {
                    currency = currencyItem;
                  });
                  Navigator.of(context).pop();
                },
                trailing: currency == currencyItem
                    ? const Icon(Icons.check, color: AppColors.primary_600)
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Helper method to format DateTime to ISO8601 string
  String _formatDateTimeToISO(DateTime date, String time) {
    if (allDay) {
      final dateTime = DateTime(date.year, date.month, date.day);
      return _formatToISO8601(dateTime);
    } else {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final dateTime = DateTime(date.year, date.month, date.day, hour, minute);
      return _formatToISO8601(dateTime);
    }
  }

  // Helper method to format DateTime to ISO8601 format without timezone conversion
  // Lưu giữ nguyên local time, thêm Z để backend accept nhưng backend sẽ lưu như local
  String _formatToISO8601(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    // Thêm Z để backend accept format, nhưng giữ nguyên giờ local (không convert)
    return '$year-$month-${day}T$hour:$minute:${second}Z';
  }

  // Helper method to format date display
  String _formatDateDisplay(DateTime date) {
    return "${date.day} thg ${date.month}, ${date.year}";
  }

  // Method to create activity
  void _createActivity() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!DateValidator.validate(
      context: context,
      allDay: allDay,
      startDate: startDate,
      startTime: startTime,
      endDate: endDate,
      endTime: endTime,
    )) {
      return; // Dừng lại nếu ngày tháng không hợp lệ (SnackBar đã được hiển thị trong DateValidator)
    }

    final request = CreateActivityRequestModel(
      title: titleController.text.trim(),
      type: "INCOME",
      day: allDay,
      timeStart: _formatDateTimeToISO(startDate, startTime),
      // Khi lặp lại: endDate = startDate, chỉ khác giờ
      timeEnd: (repeatType.isNotEmpty && repeatType != "Không")
          ? _formatDateTimeToISO(startDate, endTime)
          : _formatDateTimeToISO(endDate, endTime),
      repeat: repeatType == "Không" ? "" : repeatType,
      isRepeat: endRepeatType == "Không" ? "" : endRepeatType,
      endRepeatDay: endRepeatType == "Ngày"
          ? _formatToISO8601(repeatEndDate)
          : null,
      object: purchasedItemController.text.trim().isNotEmpty
          ? purchasedItemController.text.trim()
          : null,
      unit: unit,
      amount: quantityController.text.trim().isNotEmpty
          ? double.tryParse(quantityController.text.trim())
          : null,
      targetPerson: purchasedForController.text.trim().isNotEmpty
          ? purchasedForController.text.trim()
          : null,
      sourcePerson: buyerController.text.trim().isNotEmpty
          ? buyerController.text.trim()
          : null,
      note: noteController.text.trim().isNotEmpty
          ? noteController.text.trim()
          : null,
      money: amountController.text.trim().isNotEmpty
          ? double.tryParse(amountController.text.trim())
          : null,
      purpose: purposeController.text.trim().isNotEmpty
          ? purposeController.text.trim()
          : null,
      alertTime: alertTime != "Không" ? alertTime : null,
      attachedLink: (attachedLink != null && attachedLink!.isNotEmpty)
          ? attachedLink
          : "",
    );

    // Lấy bloc instance
    final bloc = widget.bloc ?? context.read<ActivitiesBloc>();

    // Kiểm tra xem đang ở edit mode hay create mode
    if (widget.activityToEdit != null) {
      // Update activity
      bloc.add(
        UpdateActivityEvent(id: widget.activityToEdit!.id, request: request),
      );
    } else {
      // Create new activity
      bloc.add(CreateActivityEvent(request: request));
    }
  }

  Future<void> _deleteActivity() async {
    if (widget.activityToEdit == null) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa hoạt động'),
        content: const Text('Bạn có chắc chắn muốn xóa hoạt động này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final bloc = widget.bloc ?? context.read<ActivitiesBloc>();
    bloc.add(DeleteActivityEvent(id: widget.activityToEdit!.id));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = widget.bloc ?? context.read<ActivitiesBloc>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && widget.onClose != null) {
          widget.onClose!({
            'title': titleController.text,
            'description': noteController.text,
            'startTime': startTime,
            'endTime': endTime,
            'isAllDay': allDay,
            'alertTime': alertTime,
            'repeat': repeatType,
            'endRepeatDay': repeatEndDate,
            'note': noteController.text,
            'formData': _buildFormData(),
          });
        }
      },
      child: BlocListener<ActivitiesBloc, ActivitiesState>(
        bloc: bloc,
        listenWhen: (previous, current) =>
            current is CreateActivitySuccess ||
            current is CreateActivityError ||
            current is UpdateActivitySuccess ||
            current is UpdateActivityError ||
            current is DeleteActivitySuccess ||
            current is DeleteActivityError,
        listener: (context, state) {
          if (state is CreateActivityLoading ||
              state is UpdateActivityLoading) {
            toastification.show(
              context: context,
              type: ToastificationType.info,
              style: ToastificationStyle.flat,
              title: Text(
                state is UpdateActivityLoading
                    ? 'Đang cập nhật hoạt động...'
                    : 'Đang tạo hoạt động...',
              ),
              autoCloseDuration: const Duration(seconds: 2),
              alignment: Alignment.bottomCenter,
              showProgressBar: true,
            );
          } else if (state is DeleteActivityLoading) {
            toastification.show(
              context: context,
              type: ToastificationType.info,
              style: ToastificationStyle.flat,
              title: Text('Đang xóa hoạt động...'),
              autoCloseDuration: const Duration(seconds: 2),
              alignment: Alignment.bottomCenter,
              showProgressBar: true,
            );
          } else if (state is CreateActivitySuccess) {
            widget.onSubmitSuccess?.call();

            // Schedule notification
            _scheduleNotification();

            toastification.show(
              context: context,
              type: ToastificationType.success,
              style: ToastificationStyle.flat,
              title: Text('Tạo hoạt động thành công!'),
              autoCloseDuration: const Duration(seconds: 3),
              alignment: Alignment.bottomCenter,
              showProgressBar: true,
            );
            titleController.clear();
            Navigator.of(context).pop();
          } else if (state is UpdateActivitySuccess) {
            widget.onSubmitSuccess?.call();

            // Schedule notification
            _scheduleNotification();

            toastification.show(
              context: context,
              type: ToastificationType.success,
              style: ToastificationStyle.flat,
              title: Text('Cập nhật hoạt động thành công!'),
              autoCloseDuration: const Duration(seconds: 3),
              alignment: Alignment.bottomCenter,
              showProgressBar: true,
            );
            Navigator.of(context).pop();
          } else if (state is DeleteActivitySuccess) {
            widget.onSubmitSuccess?.call();
            toastification.show(
              context: context,
              type: ToastificationType.success,
              style: ToastificationStyle.flat,
              title: Text('Xóa hoạt động thành công!'),
              autoCloseDuration: const Duration(seconds: 3),
              alignment: Alignment.bottomCenter,
              showProgressBar: true,
            );
            Navigator.of(context).pop();
          } else if (state is CreateActivityError) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              style: ToastificationStyle.flat,
              title: Text('Lỗi: ${state.message}'),
              autoCloseDuration: const Duration(seconds: 3),
              alignment: Alignment.bottomCenter,
              showProgressBar: true,
            );
          } else if (state is UpdateActivityError) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              style: ToastificationStyle.flat,
              title: Text('Lỗi cập nhật: ${state.message}'),
              autoCloseDuration: const Duration(seconds: 3),
              alignment: Alignment.bottomCenter,
              showProgressBar: true,
            );
          } else if (state is DeleteActivityError) {
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
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Row trên cùng: Loại nhật ký (trái) | Nút sát phải
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Loại nhật ký",
                        style: TextStyle(fontSize: 14.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.sp,
                          vertical: 6.sp,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFE6F4EA),
                          borderRadius: BorderRadius.circular(50.sp),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1.sp,
                          ),
                        ),
                        child: Text(
                          "Bán sản phẩm, vật tư",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                TextFormField(
                  controller: titleController,
                  validator: _validateTitle,
                  decoration: InputDecoration(
                    hintText: "Thêm tiêu đề",
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.sp,
                      horizontal: 12.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                      borderSide: BorderSide(color: Colors.green, width: 2.sp),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                      borderSide: BorderSide(color: Colors.red, width: 1.sp),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                      borderSide: BorderSide(color: Colors.red, width: 2.sp),
                    ),
                  ),
                ),
                // Cả ngày
                AddNewRow(
                  label: "Cả ngày",
                  child: Switch(
                    value: allDay,
                    onChanged: (value) => setState(() => allDay = value),
                    activeThumbColor: Colors.green,
                  ),
                ),

                // Khi lặp lại: hiển thị 3 cột (Ngày | Giờ bắt đầu | Giờ kết thúc)
                if (repeatType.isNotEmpty &&
                    repeatType != "Không" &&
                    !allDay) ...[
                  AddNewRow(
                    label: "Thời gian",
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Cột 2: Giờ bắt đầu
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () => _selectStartTime(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.sp,
                                    vertical: 8.sp,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  child: Text(
                                    startTime,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.sp),
                            Icon(Icons.arrow_forward_ios, size: 16.sp),
                            SizedBox(width: 8.sp),
                            // Cột 3: Giờ kết thúc
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () => _selectEndTime(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.sp,
                                    vertical: 8.sp,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  child: Text(
                                    endTime,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.sp),
                        Row(
                          children: [
                            // Cột 1: Ngày
                            Expanded(
                              flex: 10,
                              child: GestureDetector(
                                onTap: () => _selectStartDate(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.sp,
                                    vertical: 8.sp,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  child: Text(
                                    _formatDateDisplay(startDate),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),

                            // Cột 2: Giờ bắt đầu
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // Khi không lặp lại hoặc cả ngày: hiển thị như cũ
                if (repeatType.isEmpty || repeatType == "Không" || allDay) ...[
                  // Ngày bắt đầu
                  AddNewRow(
                    label: "Ngày bắt đầu",
                    child: Row(
                      children: [
                        if (!allDay) ...[
                          GestureDetector(
                            onTap: () => _selectStartTime(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.sp,
                                vertical: 8.sp,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8.sp),
                              ),
                              child: Text(startTime),
                            ),
                          ),
                          SizedBox(width: 8.sp),
                        ],
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectStartDate(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.sp,
                                vertical: 8.sp,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8.sp),
                              ),
                              child: Text(_formatDateDisplay(startDate)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ngày kết thúc - ẩn khi cả ngày VÀ lặp lại
                  if (!(allDay &&
                      repeatType.isNotEmpty &&
                      repeatType != "Không"))
                    AddNewRow(
                      label: "Ngày kết thúc",
                      child: Row(
                        children: [
                          if (!allDay) ...[
                            GestureDetector(
                              onTap: () => _selectEndTime(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.sp,
                                  vertical: 8.sp,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8.sp),
                                ),
                                child: Text(endTime),
                              ),
                            ),
                            SizedBox(width: 8.sp),
                          ],
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectEndDate(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.sp,
                                  vertical: 8.sp,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8.sp),
                                ),
                                child: Text(_formatDateDisplay(endDate)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],

                // Lặp lại
                AddNewRow(
                  label: "Lặp lại",
                  child: GestureDetector(
                    onTap: () => _showRepeatDialog(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.sp,
                        vertical: 8.sp,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(repeatType),
                          Icon(Icons.arrow_drop_down, size: 20.sp),
                        ],
                      ),
                    ),
                  ),
                ),

                // Kết thúc lặp lại - chỉ hiển thị khi repeatType khác "Không"
                if (repeatType.isNotEmpty && repeatType != "Không")
                  AddNewRow(
                    label: "Kết thúc lặp lại",
                    child: GestureDetector(
                      onTap: () => _showEndRepeatDialog(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.sp,
                          vertical: 8.sp,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(endRepeatType),
                            Icon(Icons.arrow_drop_down, size: 20.sp),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Ngày kết thúc - chỉ hiển thị khi chọn "Ngày"
                if (endRepeatType == "Ngày") ...[
                  AddNewRow(
                    label: "Ngày kết thúc lặp",
                    child: GestureDetector(
                      onTap: () => _selectRepeatEndDate(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.sp,
                          vertical: 8.sp,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Text(_formatDateDisplay(repeatEndDate)),
                      ),
                    ),
                  ),
                ],

                // Cảnh báo
                AddNewRow(
                  label: "Cảnh báo",
                  child: GestureDetector(
                    onTap: () => _showAlertDialog(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.sp,
                        vertical: 8.sp,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(alertTime),
                          Icon(Icons.arrow_drop_down, size: 20.sp),
                        ],
                      ),
                    ),
                  ),
                ),

                // Vật mua
                AddNewRow(
                  label: "Vật bán",
                  child: AppTextField(controller: purchasedItemController),
                ),

                // Số lượng mua
                AddNewRow(
                  label: "Số lượng bán",
                  child: AppTextField(
                    inputFormatters: [
                      // Chỉ cho phép nhập số và tối đa một dấu chấm
                      DecimalTextInputFormatter(decimalRange: 2),
                    ],
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                  ),
                ),

                // Đơn vị tính
                AddNewRow(
                  label: "Đơn vị tính",
                  child: GestureDetector(
                    onTap: () => _showUnitDialog(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.sp,
                        vertical: 8.sp,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(unit),
                          Icon(Icons.arrow_drop_down, size: 20.sp),
                        ],
                      ),
                    ),
                  ),
                ),

                // Số tiền đã chi
                AddNewRow(
                  label: "Số tiền đã nhận",
                  child: Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            DecimalTextInputFormatter(decimalRange: 2),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showCurrencyDialog(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.sp,
                              vertical: 8.sp,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8.sp),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(currency),
                                Icon(Icons.arrow_drop_down, size: 20.sp),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Mục đích
                AddNewRow(
                  label: "Mục đích",
                  child: AppTextField(controller: purposeController),
                ),

                // Mua cho ai
                AddNewRow(
                  label: "Bán cho ai",
                  child: AppTextField(controller: purchasedForController),
                ),

                // Người mua
                AddNewRow(
                  label: "Người bán",
                  child: AppTextField(controller: buyerController),
                ),

                AddNewRow(
                  label: "Hình ảnh đính kèm",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isUploadingImage)
                        Padding(
                          padding: EdgeInsets.all(8.sp),
                          child: Center(child: LoadingIndicator()),
                        )
                      else if (attachedLink != null && attachedLink!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.sp),
                              child: Image.network(
                                attachedLink!,
                                height: 200.sp,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200.sp,
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Icon(Icons.error, size: 50.sp),
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 200.sp,
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                              ),
                            ),
                            SizedBox(height: 8.sp),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _showImageSourceDialog,
                                    icon: Icon(Icons.edit, size: 18.sp),
                                    label: Text('Đổi'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary_600,
                                      side: BorderSide(
                                        color: AppColors.primary_600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.sp),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        attachedLink = "";
                                      });
                                    },
                                    icon: Icon(Icons.delete, size: 18.sp),
                                    label: Text('Xóa'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _showImageSourceDialog,
                            icon: Icon(Icons.add_photo_alternate, size: 20.sp),
                            label: Text('Upload Ảnh'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary_600,
                              side: BorderSide(color: AppColors.primary_600),
                              padding: EdgeInsets.symmetric(vertical: 12.sp),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Ghi chú
                AddNewRow(
                  label: "Ghi chú",
                  child: AppTextField(controller: noteController),
                ),

                // Save / Delete actions
                Padding(
                  padding: EdgeInsets.only(top: 16.sp),
                  child: widget.activityToEdit != null
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _deleteActivity,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.red),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12.sp,
                                  ),
                                ),
                                child: Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.sp),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _createActivity,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary_600,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12.sp,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40.sp),
                                  ),
                                ),
                                child: Text(
                                  'Lưu thay đổi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _createActivity,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary_600,
                              padding: EdgeInsets.symmetric(vertical: 12.sp),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.sp),
                              ),
                            ),
                            child: Text(
                              'Lưu Nhật ký',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
