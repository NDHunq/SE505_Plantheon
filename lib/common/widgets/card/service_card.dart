import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key});

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
            child: Icon(
              Icons.calculate,
              size: 60,
              color: AppColors.primary_main,
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'Tính toán phân bón',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary_900,
                overflow: TextOverflow.clip,
              ),
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
