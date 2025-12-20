import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';

class BlogCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final bool isNetworkImage;
  final String placeholderImagePath;
  const BlogCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.isNetworkImage = false,
    this.placeholderImagePath = 'assets/images/plants.jpg',
  });

  @override
  Widget build(BuildContext context) {
    final String effectiveImagePath = imagePath.isNotEmpty
        ? imagePath
        : placeholderImagePath;
    final ImageProvider imageProvider = isNetworkImage
        ? NetworkImage(effectiveImagePath)
        : AssetImage(effectiveImagePath);

    return Container(
      width: 140.sp,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.sp),
        border: Border.all(color: AppColors.text_color_50, width: 1.sp),
      ),
      child: Column(
        children: [
          Container(
            width: 140.sp,
            height: 114.sp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.sp),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.s12SemiBold(
                    color: AppColors.text_color_400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  description,
                  style: AppTextStyles.s10Regular(
                    color: AppColors.text_color_400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}