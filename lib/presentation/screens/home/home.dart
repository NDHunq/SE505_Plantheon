import 'package:flutter/material.dart';
import 'package:se501_plantheon/common/widgets/card/weather_card.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/history_section.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/service_section.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          spacing: 16,
          children: [WeatherCard(), ServiceSection(), HistorySection()],
        ),
      ),
    );
  }
}
