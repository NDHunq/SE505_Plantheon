import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/scan_status.dart';

class HistoryCard extends StatelessWidget {
  final String title;
  final String dateTime;
  final bool isSuccess;

  const HistoryCard({
    super.key,
    required this.title,
    required this.dateTime,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 87,
          height: 69,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/images/plants.jpg'),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.text_color_main,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateTime,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.text_color_200,
              ),
            ),
            const SizedBox(height: 4),
            ScanStatus(isSuccess: isSuccess),
          ],
        ),
      ],
    );
  }
}
