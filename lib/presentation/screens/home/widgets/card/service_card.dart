import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';

class ServiceCard extends StatelessWidget {
  final String text;
  final IconData icon;
  const ServiceCard({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        children: [
          Container(
            width: 87,
            height: 87,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.text_color_main, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 60, color: AppColors.primary_main),
          ),
          SizedBox(
            width: 80,
            child: Text(
              text,
              style: AppTextStyles.s12Medium(color: AppColors.primary_900),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
