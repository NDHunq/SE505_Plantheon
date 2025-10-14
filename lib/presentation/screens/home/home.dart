import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/weather_card.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/home/chat_bot.dart';
import 'package:se501_plantheon/presentation/screens/home/sections/disease_warning_section.dart';
import 'package:se501_plantheon/presentation/screens/home/sections/history_section.dart';
import 'package:se501_plantheon/presentation/screens/home/sections/service_section.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatBot()),
            );
          },
          backgroundColor: AppColors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.sp),
            side: BorderSide(color: AppColors.orange_400, width: 5.sp),
          ),
          child: SvgPicture.asset(
            AppVectors.chatBot, // Đường dẫn SVG của bạn
            width: 30.sp,
            height: 23.sp,
            color: AppColors.text_color_main,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
          child: SingleChildScrollView(
            child: Column(
              spacing: 16.sp,
              children: [
                WeatherCard(),
                ServiceSection(),
                HistorySection(),
                DiseaseWarningSection(),
                SizedBox(height: 16.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
