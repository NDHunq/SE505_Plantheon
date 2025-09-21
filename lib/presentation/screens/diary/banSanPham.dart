import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/common/widgets/textfield/text_field.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/diary/widgets/addNew_Row_1_2.dart';

class banSanPhamWidget extends StatefulWidget {
  const banSanPhamWidget({super.key});

  @override
  State<banSanPhamWidget> createState() => _banSanPhamWidgetState();
}

class _banSanPhamWidgetState extends State<banSanPhamWidget> {
  bool allDay = false;
  String selectedTime = "14:20";
  String selectedDate = "ngày 13 thg 7, 2025";
  String repeatType = "Không";
  String endRepeatType = "Không";
  String endDate = "ngày 13 thg 7, 2025";
  String alertTime = "Không";
  String purchasedItem = "Phân bón";
  String category = "Trồng chè";
  String quantity = "20";
  String unit = "Kg";
  String amount = "200";
  String currency = "đ";
  String purpose = "Bón vụ thu hè";
  String purchasedFor = "Chú hàng xóm";
  String buyer = "Vợ";
  String note = "Bón vụ thu hè";

  // Danh sách phân loại và đơn vị tính
  List<String> categories = ["A", "B", "C"];
  List<String> units = ["Kg", "Tấn", "Lít", "Mét", "Cái"];
  List<String> currencies = ["đ", "USD", "VND", "EUR"];

  // Phương thức chọn thời gian
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  // Phương thức chọn ngày tháng
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = "ngày ${picked.day} thg ${picked.month}, ${picked.year}";
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

  // Phương thức chọn ngày kết thúc
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        endDate = "ngày ${picked.day} thg ${picked.month}, ${picked.year}";
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    "Bán sản phẩm",
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
            contentPaddingVertical: 16,
            hintText: "Thêm tiêu đề",

            onChanged: (value) => setState(() => note = value),
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

          // Thời gian
          AddNewRow(
            label: "Thời gian",
            child: Row(
              children: [
                if (!allDay) ...[
                  GestureDetector(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(selectedTime),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Chọn ngày
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(selectedDate),
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
              label: "Ngày kết thúc",
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
                  child: Text(endDate),
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

          // Vật bán
          AddNewRow(
            label: "Vật bán",
            child: AppTextField(
              controller: TextEditingController(text: purchasedItem),
              onChanged: (value) => purchasedItem = value,
            ),
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
                    child: const Icon(Icons.add, color: Colors.blue, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Số lượng bán
          AddNewRow(
            label: "Số lượng bán",
            child: AppTextField(
              controller: TextEditingController(text: quantity),
              keyboardType: TextInputType.number,
              onChanged: (value) => quantity = value,
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
            label: "Số tiền đã thu",
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: TextEditingController(text: amount),
                    keyboardType: TextInputType.number,

                    focusedBorderWidth: 2.0,
                    onChanged: (value) => amount = value,
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
            child: AppTextField(
              controller: TextEditingController(text: purpose),
              onChanged: (value) => purpose = value,
            ),
          ),

          // bán cho ai
          AddNewRow(
            label: "Bán cho ai",
            child: AppTextField(
              controller: TextEditingController(text: purchasedFor),
              onChanged: (value) => purchasedFor = value,
            ),
          ),

          // Người bán
          AddNewRow(
            label: "Người bán",
            child: AppTextField(
              controller: TextEditingController(text: buyer),
              onChanged: (value) => buyer = value,
            ),
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
            child: AppTextField(
              controller: TextEditingController(text: note),
              onChanged: (value) => note = value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow2({required String label, required Widget child}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(label, style: const TextStyle(fontSize: 16)),
              ),
              Expanded(
                flex: 3,
                child: Align(alignment: Alignment.centerRight, child: child),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
