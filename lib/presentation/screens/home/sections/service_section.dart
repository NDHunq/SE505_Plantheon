import 'package:flutter/material.dart';
import 'package:se501_plantheon/common/widgets/card/service_card.dart';

class ServiceSection extends StatelessWidget {
  const ServiceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) =>
            ServiceCard(text: 'Tính toán phân bón', icon: Icons.local_florist),
      ),
    );
  }
}
