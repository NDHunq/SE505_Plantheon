import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:styled_divider/styled_divider.dart';

class DashDivider extends StatelessWidget {
  const DashDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: StyledDivider(
        color: AppColors.text_color_200,
        thickness: 1.sp,
        lineStyle: DividerLineStyle.dashed,
      ),
    );
  }
}