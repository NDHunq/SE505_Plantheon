import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/common/widgets/textfield/text_field.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/diary/widgets/addNew_Row_1_2.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_event.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_state.dart';
import 'package:se501_plantheon/data/models/activities_models.dart';

class chiTieuWidget extends StatefulWidget {
  const chiTieuWidget({super.key});

  @override
  State<chiTieuWidget> createState() => _chiTieuWidgetState();
}

class _chiTieuWidgetState extends State<chiTieuWidget> {
  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController purchasedItemController = TextEditingController(
    text: "Phân bón",
  );
  final TextEditingController quantityController = TextEditingController(
    text: "20",
  );
  final TextEditingController amountController = TextEditingController(
    text: "200",
  );
  final TextEditingController purposeController = TextEditingController(
    text: "Bón vụ thu hè",
  );
  final TextEditingController purchasedForController = TextEditingController(
    text: "Chú hàng xóm",
  );
  final TextEditingController buyerController = TextEditingController(
    text: "Vợ",
  );
  final TextEditingController noteController = TextEditingController(
    text: "Bón vụ thu hè",
  );

  // State variables
  bool allDay = false;
  String startTime = "14:20";
  String endTime = "15:00";
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String repeatType = "Không";
  String endRepeatType = "Không";
  DateTime repeatEndDate = DateTime.now();
  String alertTime = "Không";
  String category = "Trồng chè";
  String unit = "Kg";
  String currency = "đ";

  // Danh sách phân loại và đơn vị tính
  List<String> categories = ["A", "B", "C"];
  List<String> units = ["Kg", "Tấn", "Lít", "Mét", "Cái"];
  List<String> currencies = ["đ", "USD", "VND", "EUR"];

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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  // Phương thức hiển thị dialog chọn phân loại
  Future<void> _showCategoryDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Chọn phân loại"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((cat) {
              return ListTile(
                title: Text(cat),
                onTap: () {
                  setState(() {
                    category = cat;
                  });
                  Navigator.of(context).pop();
                },
                trailing: category == cat
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Phương thức hiển thị dialog thêm phân loại
  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Thêm phân loại"),
          content: AppTextField(
            controller: controller,
            labelText: "Nhập tên phân loại",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    categories.add(controller.text);
                    category = controller.text;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Thêm"),
            ),
          ],
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

  // Helper method to format DateTime to proper ISO8601 format (YYYY-MM-DDTHH:mm:ssZ)
  String _formatToISO8601(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '$year-$month-${day}T$hour:$minute:${second}Z';
  }

  // Helper method to format date display
  String _formatDateDisplay(DateTime date) {
    return "ngày ${date.day} thg ${date.month}, ${date.year}";
  }

  // Method to create activity
  void _createActivity() {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tiêu đề')));
      return;
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

    context.read<ActivitiesBloc>().add(CreateActivityEvent(request: request));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivitiesBloc, ActivitiesState>(
      listener: (context, state) {
        if (state is CreateActivityLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đang tạo hoạt động...')),
          );
        } else if (state is CreateActivitySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tạo hoạt động thành công!')),
          );
          // Clear form after successful creation
          titleController.clear();
          purchasedItemController.text = "Phân bón";
          quantityController.text = "20";
          amountController.text = "200";
          purposeController.text = "Bón vụ thu hè";
          purchasedForController.text = "Chú hàng xóm";
          buyerController.text = "Vợ";
          noteController.text = "Bón vụ thu hè";
        } else if (state is CreateActivityError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${state.message}')));
        }
      },
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
                      border: Border.all(color: Colors.grey.shade200, width: 1),
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

            AppTextField(
              controller: titleController,
              contentPaddingVertical: 16,
              hintText: "Thêm tiêu đề",
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

            // Phân loại
            AddNewRow(
              label: "Phân loại",
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showCategoryDialog(context),
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
                            Text(category),
                            const Icon(Icons.arrow_drop_down, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showAddCategoryDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Số lượng mua
            AddNewRow(
              label: "Số lượng mua",
              child: AppTextField(
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

            // Save button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
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
                    'Lưu Chi Tiêu',
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
    );
  }
}
