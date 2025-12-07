import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String dateTime;
  final String content;
  final bool isRead;

  const NotificationCard({
    super.key,
    required this.title,
    required this.dateTime,
    required this.isRead,
    required this.content,
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
              image: AssetImage('assets/images/noti.png'),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.s14Medium(color: AppColors.text_color_main),
            ),
            const SizedBox(height: 4),
            Text(
              dateTime,
              style: AppTextStyles.s12Regular(color: AppColors.text_color_200),
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: AppTextStyles.s12Regular(color: AppColors.text_color_200),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        Spacer(),
        Container(
          width: 8.sp,
          height: 8.sp,
          decoration: BoxDecoration(
            color: isRead ? Colors.transparent : AppColors.primary_700,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
