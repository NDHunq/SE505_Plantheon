import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class ScanStatus extends StatelessWidget {
  final bool isSuccess;

  const ScanStatus({super.key, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSuccess ? AppColors.primary_100 : Colors.red[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        child: Text(
          isSuccess ? 'Thành công' : 'Thất bại',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSuccess ? AppColors.primary_800 : AppColors.red,
          ),
        ),
      ),
    );
  }
}
