import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

Widget ActionButton({
  required String iconVector,
  required String label,
  required VoidCallback onPressed,
  Color? iconColor,
  Color? textColor,
}) {
  return Expanded(
    child: InkWell(
      onTap: onPressed,
      child: Column(
        spacing: 2,
        children: [
          SvgPicture.asset(
            iconVector,
            color: iconColor ?? AppColors.text_color_200,
            width: 24.sp,
            height: 24.sp,
          ),
          Text(
            label,
            style: AppTextStyles.s12Regular(
              color: textColor ?? AppColors.text_color_400,
            ),
          ),
        ],
      ),
    ),
  );
}
