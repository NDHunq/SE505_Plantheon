import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class BasicAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? titleColor;
  final Color? backgroundColor;

  const BasicAppbar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.titleColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      title: Text(
        title ?? 'Trợ lý ảo Bích',
        style: TextStyle(
          color: titleColor ?? AppColors.primary_700,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      leading:
          leading ??
          IconButton(
            icon: SvgPicture.asset(
              AppVectors.arrowBack,
              width: 28.sp,
              height: 28.sp,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
      actions: (actions?.isNotEmpty ?? false) ? actions : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
