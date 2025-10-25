import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/common/helpers/dayCompare.dart';
import 'package:se501_plantheon/common/helpers/decimalTextInputFormatter.dart';
import 'package:se501_plantheon/common/widgets/textfield/text_field.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/diary/widgets/addNew_Row_1_2.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_event.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_state.dart';
import 'package:se501_plantheon/data/models/activities_models.dart';
import 'package:se501_plantheon/domain/entities/activities_entities.dart';

class chiTieuWidget extends StatefulWidget {
  final DayActivityDetailEntity? activityToEdit;
  final ActivitiesBloc? bloc;
  final DateTime? initialDate;
  final VoidCallback? onSubmitSuccess;

  const chiTieuWidget({
    super.key,
    this.activityToEdit,
    this.bloc,
    this.initialDate,
    this.onSubmitSuccess,
  });

  @override
  State<chiTieuWidget> createState() => _chiTieuWidgetState();
}

class _chiTieuWidgetState extends State<chiTieuWidget> {
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
  String repeatType = "";
  String endRepeatType = "";
  DateTime repeatEndDate = DateTime.now();
  String alertTime = "";
  String category = "";
  String unit = "Kg";
  String currency = "đ";

  // Danh sách phân loại và đơn vị tính
  List<String> categories = ["A", "B", "C"];
  List<String> units = ["Kg", "Tấn", "Lít", "Mét", "Cái"];
  List<String> currencies = ["đ", "USD", "VND", "EUR"];

  // Validation methods
  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tiêu đề không được để trống';
    }
    return null;
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
      if (activity.repeat != null) {
        repeatType = activity.repeat!;
      }
      if (activity.isRepeat != null) {
        endRepeatType = activity.isRepeat!;
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
        purposeController.text = activity.purpose!.toString();
      }
    } else {
      // Nếu tạo mới, thiết lập ngày và thời gian mặc định
      _initializeDefaultDateTime();
    }
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
                    ? const Icon(Icons.check, color: Colors.green)
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
                    ? const Icon(Icons.check, color: Colors.green)
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
                    ? const Icon(Icons.check, color: Colors.green)
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
                    ? const Icon(Icons.check, color: Colors.green)
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
                    ? const Icon(Icons.check, color: Colors.green)
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
    return "ngày ${date.day} thg ${date.month}, ${date.year}";
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
      type: "EXPENSE",
      day: allDay,
      timeStart: _formatDateTimeToISO(startDate, startTime),
      timeEnd: _formatDateTimeToISO(endDate, endTime),
      repeat: repeatType != "Không" ? repeatType : null,
      isRepeat: endRepeatType != "Không" ? endRepeatType : null,
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

    return BlocListener<ActivitiesBloc, ActivitiesState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is CreateActivityLoading || state is UpdateActivityLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state is UpdateActivityLoading
                    ? 'Đang cập nhật hoạt động...'
                    : 'Đang tạo hoạt động...',
              ),
            ),
          );
        } else if (state is DeleteActivityLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đang xóa hoạt động...')),
          );
        } else if (state is CreateActivitySuccess) {
          widget.onSubmitSuccess?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tạo hoạt động thành công!')),
          );
          titleController.clear();
          Navigator.of(context).pop();
        } else if (state is UpdateActivitySuccess) {
          widget.onSubmitSuccess?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật hoạt động thành công!')),
          );
          Navigator.of(context).pop();
        } else if (state is DeleteActivitySuccess) {
          widget.onSubmitSuccess?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa hoạt động thành công!')),
          );
          Navigator.of(context).pop();
        } else if (state is CreateActivityError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${state.message}')));
        } else if (state is UpdateActivityError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi cập nhật: ${state.message}')),
          );
        } else if (state is DeleteActivityError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi xóa hoạt động: ${state.message}')),
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Loại nhật ký",
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        "Chi tiêu",
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
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
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

              // Ngày bắt đầu
              AddNewRow(
                label: "Ngày bắt đầu",
                child: Row(
                  children: [
                    if (!allDay) ...[
                      GestureDetector(
                        onTap: () => _selectStartTime(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(startTime),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectStartDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_formatDateDisplay(startDate)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Ngày kết thúc
              AddNewRow(
                label: "Ngày kết thúc",
                child: Row(
                  children: [
                    if (!allDay) ...[
                      GestureDetector(
                        onTap: () => _selectEndTime(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(endTime),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectEndDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_formatDateDisplay(endDate)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.text_color_100),

              // Lặp lại
              AddNewRow(
                label: "Lặp lại",
                child: GestureDetector(
                  onTap: () => _showRepeatDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(repeatType),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // Kết thúc lặp lại
              AddNewRow(
                label: "Kết thúc lặp lại",
                child: GestureDetector(
                  onTap: () => _showEndRepeatDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(endRepeatType),
                        const Icon(Icons.arrow_drop_down, size: 20),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_formatDateDisplay(repeatEndDate)),
                    ),
                  ),
                ),
              ],
              Divider(height: 1, color: AppColors.text_color_100),

              // Cảnh báo
              AddNewRow(
                label: "Cảnh báo",
                child: GestureDetector(
                  onTap: () => _showAlertDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(alertTime),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(height: 1, color: AppColors.text_color_100),

              // Vật mua
              AddNewRow(
                label: "Vật mua",
                child: AppTextField(controller: purchasedItemController),
              ),

              // Số lượng mua
              AddNewRow(
                label: "Số lượng mua",
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(unit),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // Số tiền đã chi
              AddNewRow(
                label: "Số tiền đã chi",
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showCurrencyDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(currency),
                              const Icon(Icons.arrow_drop_down, size: 20),
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
                label: "Mua cho ai",
                child: AppTextField(controller: purchasedForController),
              ),

              // Người mua
              AddNewRow(
                label: "Người mua",
                child: AppTextField(controller: buyerController),
              ),
              Divider(height: 1, color: AppColors.text_color_100),

              // Thêm tệp đính kèm
              AddNewRow(
                label: "Thêm tệp đính kèm...",
                child: const SizedBox.shrink(),
              ),
              Divider(height: 1, color: AppColors.text_color_100),

              // Ghi chú
              AddNewRow(
                label: "Ghi chú",
                child: AppTextField(controller: noteController),
              ),

              // Save / Delete actions
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: widget.activityToEdit != null
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _deleteActivity,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text(
                                'Xóa',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _createActivity,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              child: const Text(
                                'Lưu thay đổi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
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
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Lưu Nhật ký',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
    );
  }
}
