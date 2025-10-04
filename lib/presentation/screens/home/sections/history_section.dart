import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/home/scan_history.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/history_card.dart';

class HistorySection extends StatelessWidget {
  const HistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.sp,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lịch sử quét bệnh',
              style: AppTextStyles.s16Medium(color: AppColors.primary_700),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanHistory()),
                );
              },
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.primary_700,
              ),
            ),
          ],
        ),
        Column(
          children: [
            HistoryCard(
              title: 'Cây trồng 1',
              dateTime: '20/10/2023 14:30',
              isSuccess: true,
            ),
            Divider(
              height: 16.sp,
              color: AppColors.text_color_100,
              thickness: 1.sp,
            ),
            HistoryCard(
              title: 'Cây trồng 2',
              dateTime: '21/10/2023 10:00',
              isSuccess: false,
            ),
            Divider(
              height: 16.sp,
              color: AppColors.text_color_100,
              thickness: 1.sp,
            ),
            HistoryCard(
              title: 'Cây trồng 3',
              dateTime: '22/10/2023 09:00',
              isSuccess: true,
            ),
          ],
        ),
      ],
    );
  }
}
