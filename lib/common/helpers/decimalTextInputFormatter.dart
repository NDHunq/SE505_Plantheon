import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({this.decimalRange = 2})
    : assert(decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Nếu giá trị mới rỗng hoặc chỉ là dấu trừ, cho phép
    if (newValue.text.isEmpty || newValue.text == '-') {
      return newValue;
    }

    // Nếu giá trị mới không phải là số hợp lệ, giữ lại giá trị cũ
    if (double.tryParse(newValue.text) == null && newValue.text != '.') {
      return oldValue;
    }

    // Nếu có nhiều hơn một dấu chấm, giữ lại giá trị cũ
    if (newValue.text.split('.').length > 2) {
      return oldValue;
    }

    // Giới hạn số chữ số sau dấu phẩy
    if (newValue.text.contains('.')) {
      final parts = newValue.text.split('.');
      if (parts[1].length > decimalRange) {
        return oldValue;
      }
    }

    // Nếu tất cả đều hợp lệ, chấp nhận giá trị mới
    return newValue;
  }
}