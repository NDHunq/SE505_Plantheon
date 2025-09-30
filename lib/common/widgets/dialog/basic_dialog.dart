import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class BasicDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? child;
  final double width;

  const BasicDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.child,
    this.width = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: width < 0 ? MediaQuery.of(context).size.width * 0.8 : width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColors.primary_600,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (onCancel != null) onCancel!();
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close, color: AppColors.primary_700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (content.isNotEmpty)
              Text(
                content,
                style: TextStyle(
                  color: AppColors.text_color_main,
                  fontSize: 14,
                ),
              ),
            if (child != null) ...[const SizedBox(height: 8), child!],
            if (cancelText != null || confirmText != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (cancelText != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.text_color_100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (onCancel != null) onCancel!();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        cancelText!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  if (cancelText != null && confirmText != null)
                    const SizedBox(width: 8),
                  if (confirmText != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary_main,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (onConfirm != null) onConfirm!();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        confirmText!,
                        style: const TextStyle(
                          fontSize: 14,
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
