import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';

class ServiceCard extends StatelessWidget {
  final String name;
  final String imageUrl;

  const ServiceCard({super.key, required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        children: [
          Container(
            width: 87,
            height: 87,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.text_color_main, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: imageUrl.isNotEmpty
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
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary_main,
                            ),
                          ),
                        );
                      },
                    )
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
