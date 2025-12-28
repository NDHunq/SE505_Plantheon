import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/scan_status.dart';

class HistoryCard extends StatelessWidget {
  final String title;
  final String dateTime;
  final bool isSuccess;
  final String scanImageUrl;

  const HistoryCard({
    super.key,
    required this.title,
    required this.dateTime,
    required this.isSuccess,
    required this.scanImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.sp),
          child: scanImageUrl.isNotEmpty
              ? Image.network(
                  scanImageUrl,
                  width: 87.sp,
                  height: 69.sp,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Bone.square(
                    size: 87.sp,
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                )
              : Bone.square(
                  size: 70.sp,
                  borderRadius: BorderRadius.circular(12.sp),
                ),
        ),
        SizedBox(width: 8.sp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.s14Medium(
                  color: AppColors.text_color_main,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.sp),
              Text(
                dateTime,
                style: AppTextStyles.s12Regular(
                  color: AppColors.text_color_200,
                ),
              ),
              SizedBox(height: 4.sp),
              ScanStatus(isSuccess: isSuccess),
            ],
          ),
        ),
      ],
    );
  }
}
