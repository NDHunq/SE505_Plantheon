import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/create_post_modal.dart';

class CommunitySuggestionWidget extends StatelessWidget {
  final String? diseaseId; // className for fetching disease info
  final String? diseaseIdForPost; // UUID for creating post
  final String? scanImageUrl;
  final String? scanHistoryId;

  const CommunitySuggestionWidget({
    super.key,
    this.diseaseId,
    this.diseaseIdForPost,
    this.scanImageUrl,
    this.scanHistoryId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CreatePostModal.show(
          context,
          diseaseId: diseaseId,
          diseaseIdForPost: diseaseIdForPost,
          scanImageUrl: scanImageUrl,
          scanHistoryId: scanHistoryId,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.sp),
          border: Border.all(color: AppColors.primary_main, width: 1.sp),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4.sp,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bạn vẫn còn thắc mắc ?',
              style: AppTextStyles.s12Regular(color: Colors.black),
            ),
            Row(
              children: [
                Text(
                  'Đăng bài ngay',
                  style: AppTextStyles.s12Bold(color: AppColors.primary_main),
                ),
                SizedBox(width: 4.sp),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12.sp,
                  color: AppColors.primary_main,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
