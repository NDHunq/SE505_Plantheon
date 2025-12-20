import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:se501_plantheon/data/models/weather.model.dart';
import 'package:se501_plantheon/core/configs/enums/weather_type.dart';
import 'package:se501_plantheon/presentation/screens/scan/models/activity_ui_model.dart';
import 'package:se501_plantheon/presentation/screens/scan/widgets/reusable_activity_suggestion_item.dart';
import 'package:se501_plantheon/domain/entities/keyword_activity_entity.dart';

class WeatherSuggestionWidget extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherSuggestionWidget({super.key, required this.weatherData});

  List<Activity> _getSuggestions() {
    final List<Activity> suggestions = [];
    final now = DateTime.now();

    // 1. Gợi ý dựa trên loại thời tiết
    switch (weatherData.currentWeatherType) {
      case WeatherType.rainy:
      case WeatherType.rainThunder:
        suggestions.add(
          _createActivity(
            title: "Kiểm tra hệ thống thoát nước",
            description:
                "Mưa lớn có thể gây ngập úng. Hãy đảm bảo rãnh thoát nước được khơi thông.",
            type: ActivityType.kyThuat,
            hour: 8,
            duration: 1,
            id: 'rain_check_drain_${now.day}',
          ),
        );
        suggestions.add(
          _createActivity(
            title: "Ngưng bón phân",
            description:
                "Trời mưa dễ rửa trôi phân bón. Nên tạm ngưng bón phân.",
            type: ActivityType.kyThuat,
            hour: 9,
            duration: 0,
            id: 'rain_stop_fertilizer_${now.day}',
          ),
        );
        suggestions.add(
          _createActivity(
            title: "Phòng ngừa nấm bệnh",
            description:
                "Độ ẩm cao là điều kiện cho nấm phát triển. Kiểm tra dấu hiệu bệnh.",
            type: ActivityType.dichBenh,
            hour: 10,
            duration: 1,
            id: 'rain_fungus_check_${now.day}',
          ),
        );
        break;

      case WeatherType.sunny:
        if (weatherData.currentTemperature > 33) {
          suggestions.add(
            _createActivity(
              title: "Tưới nước bổ sung",
              description:
                  "Nhiệt độ cao (${weatherData.currentTemperature.round()}°C). Cần tưới thêm nước để giữ ẩm.",
              type: ActivityType.kyThuat,
              hour: 16,
              duration: 1,
              id: 'sunny_water_extra_${now.day}',
            ),
          );
          suggestions.add(
            _createActivity(
              title: "Che lưới lan",
              description:
                  "Nắng gắt có thể gây cháy lá. Hãy che lưới giảm nắng.",
              type: ActivityType.kyThuat,
              hour: 10,
              duration: 1,
              id: 'sunny_shade_${now.day}',
            ),
          );
        } else {
          suggestions.add(
            _createActivity(
              title: "Tưới nước sáng sớm",
              description: "Trời nắng đẹp. Nhớ tưới nước đầy đủ vào buổi sáng.",
              type: ActivityType.kyThuat,
              hour: 7,
              duration: 1,
              id: 'sunny_water_morning_${now.day}',
            ),
          );
        }
        break;

      case WeatherType.partlyCloudy:
        suggestions.add(
          _createActivity(
            title: "Kiểm tra sâu bệnh",
            description:
                "Thời tiết mát mẻ thích hợp để kiểm tra vườn và bắt sâu.",
            type: ActivityType.dichBenh,
            hour: 8,
            duration: 2,
            id: 'cloudy_pest_check_${now.day}',
          ),
        );
        suggestions.add(
          _createActivity(
            title: "Bón phân",
            description: "Thời tiết thuận lợi để bón phân cho cây.",
            type: ActivityType.kyThuat,
            hour: 9,
            duration: 1,
            id: 'cloudy_fertilizer_${now.day}',
          ),
        );
        break;

      case WeatherType.moon:
        suggestions.add(
          _createActivity(
            title: "Kiểm tra đèn chiếu sáng",
            description:
                "Đảm bảo hệ thống chiếu sáng ban đêm hoạt động tốt nếu cần.",
            type: ActivityType.kyThuat,
            hour: 19,
            duration: 1,
            id: 'moon_light_check_${now.day}',
          ),
        );
        break;
    }

    // 2. Gợi ý dựa trên gió (nếu có dữ liệu gió mạnh)
    if (weatherData.currentWindSpeed > 20) {
      suggestions.add(
        _createActivity(
          title: "Chằng chống cây",
          description:
              "Gió mạnh (${weatherData.currentWindSpeed.round()} km/h). Hãy cố định các cành cây lớn.",
          type: ActivityType.kyThuat,
          hour: 15,
          duration: 2,
          id: 'wind_support_tree_${now.day}',
        ),
      );
    }

    return suggestions;
  }

  Activity _createActivity({
    required String title,
    required String description,
    required ActivityType type,
    required int hour,
    required int duration,
    required String id,
  }) {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, hour, 0);
    final endTime = startTime.add(Duration(hours: duration));

    // Dummy entity since we don't fetch these from DB
    final dummyEntity = KeywordActivityEntity(
      id: id,
      name: title,
      description: description,
      type: _getTypeString(type),
      hourTime: hour,
      endHourTime: hour + duration,
      baseDaysOffset: 0,
      createdAt: now,
      updatedAt: now,
      isFreeTime: false,
      timeDuration: duration,
    );

    return Activity(
      title: title,
      description: description,
      type: type,
      suggestedTime: startTime,
      endTime: endTime,
      originalEntity: dummyEntity,
    );
  }

  String _getTypeString(ActivityType type) {
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

  @override
  Widget build(BuildContext context) {
    final suggestions = _getSuggestions();

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.sp, -0.sp, 16.sp, 8.sp),
          child: Text(
            'Gợi ý hôm nay',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.sp),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return ReusableActivitySuggestionItem(
                activity: suggestions[index],
              );
            },
            separatorBuilder: (context, index) => SizedBox(height: 12.sp),
          ),
        ),
      ],
    );
  }
}
