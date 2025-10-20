import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String dateTime;
  final bool isRead;

  const NotificationCard({
    super.key,
    required this.title,
    required this.dateTime,
    required this.isRead,
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
              style: AppTextStyles.s14Medium(color: AppColors.text_color_main),
            ),
            const SizedBox(height: 4),
            Text(
              dateTime,
              style: AppTextStyles.s12Regular(color: AppColors.text_color_200),
            ),
            const SizedBox(height: 4),
            _NotificationStatus(isRead: isRead),
          ],
        ),
      ],
    );
  }
}

class _NotificationStatus extends StatelessWidget {
  final bool isRead;

  const _NotificationStatus({required this.isRead});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isRead
            ? AppColors.text_color_100.withOpacity(0.1)
            : AppColors.primary_100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        child: Text(
          isRead ? 'Đã đọc' : 'Chưa đọc',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isRead ? AppColors.text_color_200 : AppColors.primary_800,
          ),
        ),
      ),
    );
  }
}
