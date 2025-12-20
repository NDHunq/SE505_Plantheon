import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';

class SettingListItem extends StatelessWidget {
  final Widget leading;
  final String text;
  final Widget action;
  final bool isHavePadding;
  const SettingListItem({
    super.key,
    required this.leading,
    required this.text,
    required this.action,
    this.isHavePadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 8.sp,
        vertical: isHavePadding ? 12.sp : 0,
      ),
      child: Row(
        children: [
          leading,
          SizedBox(width: 16.sp),
          Text(text, style: AppTextStyles.s14Medium()),
          Spacer(),
          action,
        ],
      ),
    );
  }
}