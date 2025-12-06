import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';

class PlantsCard extends StatelessWidget {
  final String name;
  final String imageUrl;

  const PlantsCard({super.key, required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        spacing: 4.sp,
        children: [
          Container(
            width: 87,
            height: 87,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.text_color_main, width: 1),
              borderRadius: BorderRadius.circular(50.sp),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50.sp),
              child: imageUrl.isNotEmpty
                  ? (kIsWeb
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.local_florist,
                              size: 36,
                              color: AppColors.primary_main,
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: LoadingIndicator(),
                                ),
                              );
                            },
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: LoadingIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.local_florist,
                              size: 36,
                              color: AppColors.primary_main,
                            ),
                          ))
                  : Icon(
                      Icons.local_florist,
                      size: 36,
                      color: AppColors.primary_main,
                    ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              name,
              style: AppTextStyles.s12Medium(color: AppColors.primary_900),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
