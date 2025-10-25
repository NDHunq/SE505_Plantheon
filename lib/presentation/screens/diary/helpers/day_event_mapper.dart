import 'package:flutter/material.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_state.dart';
import 'package:se501_plantheon/presentation/screens/diary/models/day_event.dart';

class DayEventMapper {
  static List<DayEvent> mapDayActivitiesToEvents(
    DayActivitiesLoaded state,
    DateTime viewDate,
  ) {
    // Chỉ lấy các activities có day = false (không phải cả ngày)
    return state.data.activities.where((a) => !a.day).map((a) {
      final localStart = a.timeStart.toLocal();
      final localEnd = a.timeEnd.toLocal();

      // So sánh ngày (không tính giờ)
      final DateTime startDate = DateTime(
        localStart.year,
        localStart.month,
        localStart.day,
      );
      final DateTime endDate = DateTime(
        localEnd.year,
        localEnd.month,
        localEnd.day,
      );

      int startHour;
      int endHour;

      // Nếu activity bắt đầu trước viewDate thì hiển thị từ 0h
      if (startDate.isBefore(viewDate)) {
        startHour = 0;
      } else {
        startHour = localStart.hour;
      }

      // Nếu activity kết thúc sau viewDate thì hiển thị đến 24h
      if (endDate.isAfter(viewDate)) {
        endHour = 24;
      } else {
        // Nếu endHour = 0 (midnight) thì coi như activity kéo dài đến 24h của ngày hôm trước
        if (localEnd.hour == 0 && localEnd.minute == 0) {
          endHour = 24;
        } else if (localEnd.hour == localStart.hour && startDate == endDate) {
          // Cùng giờ, thêm 1 để hiển thị ít nhất 1 giờ
          endHour = localStart.hour + 1;
        } else {
          // Nếu có phút thì làm tròn lên giờ tiếp theo
          endHour = localEnd.minute > 0 ? localEnd.hour + 1 : localEnd.hour;
        }
      }

      print(
        '[DayEventMapper] Activity: ${a.title}, start: $localStart, end: $localEnd, startHour: $startHour, endHour: $endHour',
      );

      final String amountText = _amountTextByType(a.type);
      final Color activityColor = _getColorByType(a.type);
      return DayEvent(
        id: a.id,
        startHour: startHour.clamp(0, 23),
        endHour: endHour.clamp(1, 24),
        title: a.title,
        type: a.type,
        day: a.day,
        realStartTime: localStart,
        realEndTime: localEnd,
        amountText: amountText,
        color: activityColor,
      );
    }).toList();
  }

  static String _amountTextByType(String type) {
    switch (type.toUpperCase()) {
      case 'EXPENSE':
        return 'Chi tiêu';
      case 'INCOME':
        return 'Thu nhập';
      case 'DISEASE':
        return 'Dịch bệnh';
      case 'TECHNIQUE':
        return 'Kỹ thuật';
      case 'CLIMATE':
        return 'Thích ứng BĐKH';
      case 'OTHER':
        return 'Khác';
      default:
        return '';
    }
  }

  static Color _getColorByType(String type) {
    switch (type.toUpperCase()) {
      case 'EXPENSE':
        return Colors.red;
      case 'INCOME':
        return Colors.green;
      case 'DISEASE':
        return Colors.orange;
      case 'TECHNIQUE':
        return Colors.blue;
      case 'CLIMATE':
        return Colors.teal;
      case 'OTHER':
        return Colors.purple;
      default:
        return Colors.blueGrey;
    }
  }
}
