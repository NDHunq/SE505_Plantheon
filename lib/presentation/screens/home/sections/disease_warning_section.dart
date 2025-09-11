import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/disease_card.dart';

class DiseaseWarningSection extends StatelessWidget {
  const DiseaseWarningSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cảnh báo sâu hại & dịch bệnh',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primary_700,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.primary_700,
            ),
          ],
        ),
        SizedBox(
          height: 200, // Adjust height as needed for your card
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4, // Replace with your actual item count
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: DiseaseWarningCard(
                  title: 'Bệnh rệp sáp trên cây trồng',
                  description:
                      'Rệp sáp là một loại côn trùng gây hại cho cây trồng.',
                  imagePath: 'assets/images/plants.jpg',
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
