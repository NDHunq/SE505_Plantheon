import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class BasicDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? child;
  final double? width;

  const BasicDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.child,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
      contentPadding: EdgeInsets.all(12.sp),
      content: SizedBox(
        width: width ?? MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primary_600,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close_rounded, color: AppColors.primary_700),
                ),
              ],
            ),
            SizedBox(height: 8.sp),
            if (content.isNotEmpty)
              Text(
                content,
                style: TextStyle(
                  color: AppColors.text_color_main,
                  fontSize: 14.sp,
                ),
              ),
            if (child != null) ...[SizedBox(height: 8.sp), child!],
            if (cancelText != null || confirmText != null) ...[
              SizedBox(height: 16.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (cancelText != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        side: BorderSide(
                          color: AppColors.primary_main,
                          width: 1.sp,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                      ),
                      onPressed: () {
                        if (onCancel != null) onCancel!();
                      },
                      child: Text(
                        cancelText!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary_main,
                        ),
                      ),
                    ),
                  if (cancelText != null && confirmText != null)
                    SizedBox(width: 8.sp),
                  if (confirmText != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary_main,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                      ),
                      onPressed: () {
                        if (onConfirm != null) onConfirm!();
                      },
                      child: Text(
                        confirmText!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
