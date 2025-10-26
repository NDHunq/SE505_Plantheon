import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class DetailNews extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final String category;
  final String date;
  final String markdownContent;

  const DetailNews({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.category = 'Tin tức',
    this.date = '15 phút trước',
    this.markdownContent = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: BasicAppbar(
        title: 'Chi tiết tin tức',
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              AppVectors.share,
              height: 24.sp,
              width: 24.sp,
            ),
            onPressed: () {
              // Handle share
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Title and Category
            Container(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.sp,
                      vertical: 6.sp,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary_50,
                      borderRadius: BorderRadius.circular(16.sp),
                    ),
                    child: Text(
                      category,
                      style: AppTextStyles.s14Medium(
                        color: AppColors.primary_700,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.sp),
                  // Title
                  Text(
                    title,
                    style: AppTextStyles.s24Bold(
                      color: AppColors.text_color_main,
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  // Date and author
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14.sp,
                        color: AppColors.text_color_200,
                      ),
                      SizedBox(width: 4.sp),
                      Text(
                        date,
                        style: AppTextStyles.s12Regular(
                          color: AppColors.text_color_200,
                        ),
                      ),
                      SizedBox(width: 16.sp),
                      Icon(
                        Icons.person_outline,
                        size: 14.sp,
                        color: AppColors.text_color_200,
                      ),
                      SizedBox(width: 4.sp),
                      Text(
                        'Tác giả',
                        style: AppTextStyles.s12Regular(
                          color: AppColors.text_color_200,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Image
            Container(
              height: 250.sp,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Content Section
            Padding(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    description,
                    style: AppTextStyles.s16Regular(
                      color: AppColors.text_color_400,
                    ),
                  ),
                  SizedBox(height: 16.sp),

                  // Markdown Content
                  if (markdownContent.isNotEmpty) ...[
                    MarkdownBody(
                      data: markdownContent,
                      styleSheet: MarkdownStyleSheet(
                        h1: AppTextStyles.s24Bold(color: AppColors.primary_700),
                        h2: AppTextStyles.s20Bold(color: AppColors.primary_600),
                        h3: AppTextStyles.s16Bold(color: AppColors.primary_600),
                        p: AppTextStyles.s14Regular(
                          color: AppColors.text_color_400,
                        ),
                        strong: AppTextStyles.s14Bold(
                          color: AppColors.text_color_main,
                        ),
                        em: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14.sp,
                          color: AppColors.text_color_400,
                        ),
                        code: TextStyle(
                          fontSize: 12.sp,
                          backgroundColor: AppColors.text_color_50.withOpacity(
                            0.3,
                          ),
                          color: AppColors.primary_700,
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: AppColors.text_color_50.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        blockquote: TextStyle(
                          fontSize: 14.sp,
                          fontStyle: FontStyle.italic,
                          color: AppColors.text_color_300,
                        ),
                        blockquoteDecoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppColors.primary_main,
                              width: 4.sp,
                            ),
                          ),
                        ),
                        listBullet: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primary_main,
                        ),
                        listIndent: 16.sp,
                      ),
                      selectable: true,
                    ),
                    SizedBox(height: 24.sp),
                  ],

                  // Related Topics Section
                  Text(
                    'Chủ đề liên quan',
                    style: AppTextStyles.s16Bold(color: AppColors.primary_700),
                  ),
                  SizedBox(height: 12.sp),
                  Wrap(
                    spacing: 8.sp,
                    runSpacing: 8.sp,
                    children: [
                      _buildTopicChip('Bệnh cây'),
                      _buildTopicChip('Kỹ thuật trồng'),
                      _buildTopicChip('Phân bón'),
                      _buildTopicChip('Chăm sóc'),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8.sp,
                    offset: Offset(0, -2.sp),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Handle like
                      },
                      icon: Icon(
                        Icons.thumb_up_outlined,
                        size: 20.sp,
                        color: AppColors.primary_main,
                      ),
                      label: Text(
                        'Thích',
                        style: AppTextStyles.s14Medium(
                          color: AppColors.primary_main,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.sp),
                        side: BorderSide(
                          color: AppColors.primary_main,
                          width: 1.sp,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.sp),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Handle share
                      },
                      icon: Icon(
                        Icons.share_outlined,
                        size: 20.sp,
                        color: AppColors.white,
                      ),
                      label: Text(
                        'Chia sẻ',
                        style: AppTextStyles.s14Bold(color: AppColors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.sp),
                        backgroundColor: AppColors.primary_main,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.sp),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
      decoration: BoxDecoration(
        color: AppColors.text_color_50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(color: AppColors.text_color_50, width: 1.sp),
      ),
      child: Text(
        label,
        style: AppTextStyles.s12Medium(color: AppColors.text_color_400),
      ),
    );
  }
}
