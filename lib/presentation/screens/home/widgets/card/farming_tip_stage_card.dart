import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class FarmingTipStageCard extends StatelessWidget {
  final String vectorAsset;
  final String stageLabel;
  final String stageDescription;
  final String stageTime;
  final bool isNow;

  const FarmingTipStageCard({
    super.key,
    required this.vectorAsset,
    required this.stageLabel,
    required this.stageDescription,
    required this.stageTime,
    this.isNow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isNow ? AppColors.primary_300 : Colors.transparent,
        border: const Border(
          bottom: BorderSide(color: AppColors.text_color_200, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        spacing: 16,
        children: [
          SvgPicture.asset(vectorAsset, width: 60, height: 60),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isNow ? AppColors.white : AppColors.text_color_200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    stageLabel,
                    style: TextStyle(
                      color: isNow ? AppColors.white : AppColors.text_color_200,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  stageDescription,
                  style: TextStyle(
                    color: isNow ? AppColors.white : AppColors.text_color_200,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  stageTime,
                  style: TextStyle(
                    color: isNow ? AppColors.white : AppColors.text_color_400,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isNow ? AppColors.white : AppColors.text_color_50,
          ),
        ],
      ),
    );
  }
}
