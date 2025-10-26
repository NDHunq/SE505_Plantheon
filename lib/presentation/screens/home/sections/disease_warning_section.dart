import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/blogs/blogs.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/disease_card.dart';

class DiseaseWarningSection extends StatelessWidget {
  const DiseaseWarningSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.sp,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tin tức',
              style: AppTextStyles.s16Medium(color: AppColors.primary_700),
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Blogs()),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.primary_700,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 200.sp, // Adjust height as needed for your card
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4, // Replace with your actual item count
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 8.sp),
                child: DiseaseWarningCard(
                  title: 'Bệnh rệp sáp trên cây trồng',
                  description:
                      'Rệp sáp là một loại côn trùng gây hại cho cây trồng.',
                  imagePath: 'assets/images/plants.jpg',
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
