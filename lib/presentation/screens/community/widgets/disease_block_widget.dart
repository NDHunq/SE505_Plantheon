import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class DiseaseBlockWidget extends StatefulWidget {
  final String? diseaseLink;
  final String? diseaseName;
  final String? diseaseDescription;
  final String? diseaseSolution;
  final String? diseaseImageLink;
  final String? scanHistoryId;
  final List<String>? postImageLinks;

  const DiseaseBlockWidget({
    super.key,
    this.diseaseLink,
    this.diseaseName,
    this.diseaseDescription,
    this.diseaseSolution,
    this.diseaseImageLink,
    this.scanHistoryId,
    this.postImageLinks,
  });

  @override
  State<DiseaseBlockWidget> createState() => _DiseaseBlockWidgetState();
}

class _DiseaseBlockWidgetState extends State<DiseaseBlockWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Only show if there's a disease link
    if (widget.diseaseLink == null || widget.diseaseLink!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.sp),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: AppColors.orange_400, width: 1.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collapsed header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12.sp),
            child: Padding(
              padding: EdgeInsets.all(12.sp),
              child: Row(
                children: [
                  // Disease image thumbnail
                  if (widget.diseaseImageLink != null &&
                      widget.diseaseImageLink!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.sp),
                      child: Image.network(
                        widget.diseaseImageLink!,
                        width: 60.sp,
                        height: 60.sp,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60.sp,
                            height: 60.sp,
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8.sp),
                            ),
                            child: Icon(
                              Icons.bug_report,
                              size: 30.sp,
                              color: AppColors.orange,
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(width: 12.sp),
                  // Disease name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppVectors.warning,
                              width: 16.sp,
                              height: 16.sp,
                              color: AppColors.orange,
                            ),
                            SizedBox(width: 4.sp),
                            Text(
                              'Chẩn đoán',
                              style: AppTextStyles.s12Regular(
                                color: AppColors.orange,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.sp),
                        Text(
                          widget.diseaseName ?? 'Không xác định',
                          style: AppTextStyles.s12Bold(
                            color: AppColors.text_color_main,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Expand/collapse icon
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.orange,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (_isExpanded) ...[
            Container(height: 1.sp, color: AppColors.orange_400),
            Padding(
              padding: EdgeInsets.all(12.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description section
                  if (widget.diseaseDescription != null &&
                      widget.diseaseDescription!.isNotEmpty) ...[
                    Text(
                      'Mô tả',
                      style: AppTextStyles.s12Bold(
                        color: AppColors.text_color_main,
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    MarkdownBody(
                      data: widget.diseaseDescription!,
                      styleSheet: MarkdownStyleSheet(
                        p: AppTextStyles.s12Regular(
                          color: AppColors.text_color_main,
                        ),
                        h2: AppTextStyles.s14Bold(
                          color: AppColors.text_color_main,
                        ),
                        h3: AppTextStyles.s12Bold(
                          color: AppColors.text_color_main,
                        ),
                        listBullet: AppTextStyles.s12Regular(
                          color: AppColors.text_color_main,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.sp),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
