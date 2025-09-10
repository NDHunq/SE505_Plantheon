

import 'package:flutter/material.dart';
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
        selectedTime = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
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
      "Hàng năm"
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
                trailing: repeatType == option ? const Icon(Icons.check, color: Colors.green) : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Phương thức hiển thị dialog chọn kết thúc lặp lại
  Future<void> _showEndRepeatDialog(BuildContext context) async {
    final List<String> endRepeatOptions = [
      "Không",
      "Ngày"
    ];

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
                trailing: endRepeatType == option ? const Icon(Icons.check, color: Colors.green) : null,
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
    final List<String> alertOptions = [
      "Không",
      "Trước 5 phút",
      "Trước 1 ngày"
    ];

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
                trailing: alertTime == option ? const Icon(Icons.check, color: Colors.green) : null,
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
                trailing: category == cat ? const Icon(Icons.check, color: Colors.green) : null,
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
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Nhập tên phân loại",
              border: OutlineInputBorder(),
            ),
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
                trailing: unit == unitItem ? const Icon(Icons.check, color: Colors.green) : null,
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
                trailing: currency == currencyItem ? const Icon(Icons.check, color: Colors.green) : null,
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
          TextField(
            decoration: InputDecoration(
              labelText: "Thêm tiêu đề",
              
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => note = value),
          ),
        
          Container(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                 Text("Chi Tiêu"),
                ],
              ),
            ),
          ),
          // Cả ngày
          _buildFormRow2(
            label: "Cả ngày",
            child: Switch(
              value: allDay,
              onChanged: (value) => setState(() => allDay = value),
              activeColor: Colors.green,
            ),
          ),
          
          // Thời gian
          _buildFormRow(
            label: "Thời gian",
            child: Row(
              children: [
                // Chọn giờ
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(selectedTime),
                  ),
                ),
                const SizedBox(width: 8),
                // Chọn ngày
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          
          // Lặp lại
          _buildFormRow(
            label: "Lặp lại",
            child: GestureDetector(
              onTap: () => _showRepeatDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          _buildFormRow(
            label: "Kết thúc lặp lại",
            child: GestureDetector(
              onTap: () => _showEndRepeatDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            _buildFormRow(
              label: "Ngày kết thúc",
              child: GestureDetector(
                onTap: () => _selectEndDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(endDate),
                ),
              ),
            ),
          ],
          
          // Cảnh báo
          _buildFormRow(
            label: "Cảnh báo",
            child: GestureDetector(
              onTap: () => _showAlertDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          
          // Vật mua
          _buildFormRow(
            label: "Vật mua",
            child: TextField(
              controller: TextEditingController(text: purchasedItem),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) => purchasedItem = value,
            ),
          ),
          
          // Phân loại
          _buildFormRow(
            label: "Phân loại",
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCategoryDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          
          // Số lượng mua
          _buildFormRow(
            label: "Số lượng mua",
            child: TextField(
              controller: TextEditingController(text: quantity),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => quantity = value,
            ),
          ),
          
          // Đơn vị tính
          _buildFormRow(
            label: "Đơn vị tính",
            child: GestureDetector(
              onTap: () => _showUnitDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          _buildFormRow(
            label: "Số tiền đã thu",
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: amount),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => amount = value,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCurrencyDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          _buildFormRow(
            label: "Mục đích",
            child: TextField(
              controller: TextEditingController(text: purpose),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) => purpose = value,
            ),
          ),
          
          // Mua cho ai
          _buildFormRow(
            label: "Bán cho ai",
            child: TextField(
              controller: TextEditingController(text: purchasedFor),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) => purchasedFor = value,
            ),
          ),
          
          // Người mua
          _buildFormRow(
            label: "Người b",
            child: TextField(
              controller: TextEditingController(text: buyer),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) => buyer = value,
            ),
          ),
          
          // Thêm tệp đính kèm
          _buildFormRow(
            label: "Thêm tệp đính kèm...",
            child: const SizedBox.shrink(),
          ),
          
          // Ghi chú
          _buildFormRow(
            label: "Ghi chú",
            child: TextField(
              controller: TextEditingController(text: note),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) => note = value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow({required String label, required Widget child}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                flex: 3,
                child: child,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
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
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                flex: 3,
                child: child,
              ),
            ],
          ),
        ),
       
      ],
    );
  }
}
