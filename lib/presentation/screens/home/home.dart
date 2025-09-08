import 'package:flutter/material.dart';
import 'package:se501_plantheon/common/widgets/card/service_card.dart';
import 'package:se501_plantheon/common/widgets/card/weather_card.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          spacing: 16,
          children: [
            WeatherCard(),
            SizedBox(
              height: 200, // adjust height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) => ServiceCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
