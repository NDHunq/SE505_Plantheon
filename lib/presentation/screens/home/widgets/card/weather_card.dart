import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/presentation/screens/home/weather.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Weather()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.text_color_50, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            spacing: 10.0,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary_main,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(Icons.menu, size: 24, color: Colors.white),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hôm nay,',
                    style: AppTextStyles.s16Medium(
                      color: AppColors.primary_main,
                    ),
                  ),
                  Text(
                    'Mưa có sấm chớp',
                    style: AppTextStyles.s12Regular(
                      color: AppColors.text_color_200,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Text(
                '28°C',
                style: AppTextStyles.s20Bold(color: AppColors.primary_600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
