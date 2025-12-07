import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:toastification/toastification.dart';

class ReportButton extends StatelessWidget {
  const ReportButton({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            String? selectedReason;
            TextEditingController otherController = TextEditingController();
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(
                    'Báo cáo bài viết',
                    style: AppTextStyles.s14Bold(),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile<String>(
                        title: Text(
                          'Nội dung không phù hợp',
                          style: AppTextStyles.s12Regular(),
                        ),
                        value: 'Nội dung không phù hợp',
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setState(() => selectedReason = value);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'Spam hoặc quảng cáo',
                          style: AppTextStyles.s12Regular(),
                        ),
                        value: 'Spam hoặc quảng cáo',
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setState(() => selectedReason = value);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'Thông tin sai sự thật',
                          style: AppTextStyles.s12Regular(),
                        ),
                        value: 'Thông tin sai sự thật',
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setState(() => selectedReason = value);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'Ngôn từ gây thù ghét',
                          style: AppTextStyles.s12Regular(),
                        ),
                        value: 'Ngôn từ gây thù ghét',
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setState(() => selectedReason = value);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'Bạo lực hoặc đe dọa',
                          style: AppTextStyles.s12Regular(),
                        ),
                        value: 'Bạo lực hoặc đe dọa',
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setState(() => selectedReason = value);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'Nội dung nhạy cảm (18+)',
                          style: AppTextStyles.s12Regular(),
                        ),
                        value: 'Nội dung nhạy cảm (18+)',
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setState(() => selectedReason = value);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(
                          'Vi phạm bản quyền',
                          style: AppTextStyles.s12Regular(),
                        ),
                        value: 'Vi phạm bản quyền',
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setState(() => selectedReason = value);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text('Khác', style: AppTextStyles.s12Regular()),
                        value: 'Khác',
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setState(() => selectedReason = value);
                        },
                      ),
                      if (selectedReason == 'Khác')
                        Padding(
                          padding: EdgeInsets.only(left: 16.sp, top: 8.sp),
                          child: TextField(
                            controller: otherController,
                            decoration: InputDecoration(
                              hintText: 'Nhập lý do khác...',
                            ),
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary_main,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Hủy', style: AppTextStyles.s12Regular()),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary_main,
                      ),
                      onPressed:
                          selectedReason == null ||
                              (selectedReason == 'Khác' &&
                                  otherController.text.trim().isEmpty)
                          ? null
                          : () {
                              // Xử lý gửi báo cáo ở đây nếu muốn
                              Navigator.of(context).pop();
                              toastification.show(
                                context: context,
                                type: ToastificationType.success,
                                style: ToastificationStyle.flat,
                                title: Text('Đã gửi báo cáo.'),
                                autoCloseDuration: const Duration(seconds: 3),
                                alignment: Alignment.bottomCenter,
                                showProgressBar: true,
                              );
                            },
                      child: Text(
                        'Gửi',
                        style: AppTextStyles.s12Regular(color: AppColors.white),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
      child: SvgPicture.asset(
        AppVectors.postReport,
        width: 20.sp,
        height: 20.sp,
        color: Colors.grey[600],
      ),
    );
  }
}
