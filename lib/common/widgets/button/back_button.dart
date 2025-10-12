import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class buildBackButton extends StatelessWidget {
  const buildBackButton({super.key, required this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        if (onBackPressed != null) {
          // Show loading briefly for back action
          await Future.delayed(const Duration(milliseconds: 200));
          onBackPressed!();
        } else {
          Navigator.of(context).pop();
        }
      },
      icon: SvgPicture.asset(
        AppVectors.arrowBack,
        width: 30,
        height: 30,
        color: AppColors.primary_600,
      ),
    );
  }
}
