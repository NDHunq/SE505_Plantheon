import 'package:flutter/material.dart';
import 'package:se501_plantheon/presentation/screens/home/farming_tips.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/service_card.dart';

class ServiceSection extends StatelessWidget {
  const ServiceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FarmingTips()),
            );
          },
          child: ServiceCard(
            text: 'Tính toán phân bón',
            icon: Icons.local_florist,
          ),
        ),
      ),
    );
  }
}
