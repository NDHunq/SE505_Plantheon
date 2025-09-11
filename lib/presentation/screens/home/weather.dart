import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/enums/weather_type.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/weather_card.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/weather_horizontal_card.dart';

class Weather extends StatelessWidget {
  const Weather({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary_400,
      appBar: BasicAppbar(
        title: "Bình Thạnh",
        titleColor: AppColors.white,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppVectors.arrowBack,
            width: 28,
            height: 28,
            color: AppColors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              AppVectors.location,
              width: 24,
              height: 24,
              color: AppColors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        spacing: 24,
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 60,
            children: [
              SvgPicture.asset(
                AppVectors.weatherPartlyCloudy,
                width: 110,
                height: 110,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    "Hôm nay, 11 tháng 9",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary_700,
                    ),
                  ),
                  Text(
                    "27°C",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    "Nhiều mây",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary_700,
                    ),
                  ),
                  Text(
                    "Độ ẩm: 78% - Gió: 10 km/h",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary_700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              spacing: 24,
              children: [
                WeatherVerticalCard(
                  temperature: 27,
                  hour: 14,
                  weatherType: WeatherType.partlyCloudy,
                ),
                WeatherVerticalCard(
                  temperature: 26,
                  hour: 15,
                  weatherType: WeatherType.sunny,
                ),
                WeatherVerticalCard(
                  temperature: 26,
                  hour: 16,
                  weatherType: WeatherType.sunny,
                  isNow: true,
                ),
                WeatherVerticalCard(
                  temperature: 25,
                  hour: 17,
                  weatherType: WeatherType.partlyCloudy,
                ),
                WeatherVerticalCard(
                  temperature: 24,
                  hour: 18,
                  weatherType: WeatherType.rainy,
                ),
                WeatherVerticalCard(
                  temperature: 24,
                  hour: 19,
                  weatherType: WeatherType.moon,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary_200,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dự báo kế tiếp",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary_700,
                        ),
                      ),
                      WeatherHorizontalCard(
                        date: "Hôm nay",
                        temperature: 27,
                        weatherType: WeatherType.partlyCloudy,
                      ),
                      WeatherHorizontalCard(
                        date: "Ngày mai",
                        temperature: 28,
                        weatherType: WeatherType.sunny,
                      ),
                      WeatherHorizontalCard(
                        date: "Thứ Sáu",
                        temperature: 26,
                        weatherType: WeatherType.rainy,
                      ),
                      WeatherHorizontalCard(
                        date: "Thứ Bảy",
                        temperature: 25,
                        weatherType: WeatherType.rainThunder,
                      ),
                      WeatherHorizontalCard(
                        date: "Chủ Nhật",
                        temperature: 27,
                        weatherType: WeatherType.partlyCloudy,
                      ),
                      WeatherHorizontalCard(
                        date: "Thứ Hai",
                        temperature: 28,
                        weatherType: WeatherType.sunny,
                      ),
                      WeatherHorizontalCard(
                        date: "Thứ Ba",
                        temperature: 29,
                        weatherType: WeatherType.sunny,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
