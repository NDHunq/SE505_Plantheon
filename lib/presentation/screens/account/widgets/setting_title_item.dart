import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class SettingTitleItem extends StatelessWidget {
  final String text;
  const SettingTitleItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.sp),
      child: Text(
        text,
        style: AppTextStyles.s16Bold(color: AppColors.text_color_main),
      ),
    );
  }
}
