import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class PlantsDropdown extends StatelessWidget {
  const PlantsDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary_700, width: 1),
      ),
      child: Row(
        spacing: 16,
        children: [
          SvgPicture.asset(AppVectors.weatherSunny, width: 16, height: 16),
          Text(
            "Cam",
            style: TextStyle(
              color: AppColors.text_color_200,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.text_color_200,
          ),
        ],
      ),
    );
  }
}
