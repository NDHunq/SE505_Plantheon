import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class DateValidator {
  /// Hàm kết hợp ngày (từ DateTime) và giờ (từ String) lại với nhau.
  static DateTime _combineDateAndTime(DateTime date, String time) {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// Kiểm tra xem ngày/giờ kết thúc có hợp lệ so với ngày/giờ bắt đầu không.
  /// Trả về `true` nếu hợp lệ, `false` nếu không.
  /// Tự động hiển thị SnackBar khi có lỗi.
  static bool validate({
    required BuildContext context,
    required bool allDay,
    required DateTime startDate,
    required String startTime,
    required DateTime endDate,
    required String endTime,
    bool useRootNavigator = true, // Thêm parameter để sử dụng root context
  }) {
    DateTime finalStartDate;
    DateTime finalEndDate;

    if (allDay) {
      // Nếu là sự kiện "Cả ngày", chỉ so sánh ngày
      finalStartDate = DateTime(startDate.year, startDate.month, startDate.day);
      finalEndDate = DateTime(endDate.year, endDate.month, endDate.day);

      if (finalStartDate.isAfter(finalEndDate)) {
        _showErrorDialog(
          context,
          'Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.',
        );
        return false; // Validation thất bại
      }
    } else {
      // Nếu không phải "Cả ngày", gộp cả ngày và giờ để so sánh
      finalStartDate = _combineDateAndTime(startDate, startTime);
      finalEndDate = _combineDateAndTime(endDate, endTime);

      if (finalStartDate.isAfter(finalEndDate)) {
        _showErrorDialog(
          context,
          'Thời gian kết thúc phải sau thời gian bắt đầu.',
        );
        return false; // Validation thất bại
      }
    }

    return true; // Validation thành công
  }

  /// Hiển thị dialog lỗi thay vì SnackBar để tránh bị che bởi BottomSheet
  /// Hiển thị Toast lỗi thay vì Dialog
  static void _showErrorDialog(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: const Text('Lỗi'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.bottomCenter,
      showProgressBar: true,
    );
  }
}