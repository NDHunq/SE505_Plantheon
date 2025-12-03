import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/scan/scan_solution.dart';

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
      margin: EdgeInsets.symmetric(vertical: 8.sp),
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
                  if (widget.postImageLinks != null &&
                      widget.postImageLinks!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.sp),
                      child: Image.network(
                        widget.postImageLinks!.first,
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
                            Icon(
                              Icons.warning_rounded,
                              size: 14.sp,
                              color: AppColors.orange,
                            ),
                            SizedBox(width: 4.sp),
                            Text(
                              'Bệnh phát hiện',
                              style: AppTextStyles.s10Regular(
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
                    Html(
                      data: widget.diseaseDescription!,
                      style: {
                        "body": Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          fontSize: FontSize(12.sp),
                          color: AppColors.text_color_main,
                        ),
                        "p": Style(margin: Margins.only(bottom: 8.sp)),
                        "h2": Style(
                          fontSize: FontSize(14.sp),
                          fontWeight: FontWeight.bold,
                          margin: Margins.only(top: 8.sp, bottom: 4.sp),
                        ),
                        "h3": Style(
                          fontSize: FontSize(12.sp),
                          fontWeight: FontWeight.bold,
                          margin: Margins.only(top: 8.sp, bottom: 4.sp),
                        ),
                        "ul": Style(
                          margin: Margins.only(left: 16.sp, bottom: 8.sp),
                        ),
                        "li": Style(margin: Margins.only(bottom: 4.sp)),
                      },
                    ),
                    SizedBox(height: 12.sp),
                  ],
                  // Solution section
                  if (widget.diseaseSolution != null &&
                      widget.diseaseSolution!.isNotEmpty) ...[
                    Text(
                      'Giải pháp',
                      style: AppTextStyles.s12Bold(
                        color: AppColors.text_color_main,
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    Html(
                      data: widget.diseaseSolution!,
                      style: {
                        "body": Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          fontSize: FontSize(12.sp),
                          color: AppColors.text_color_main,
                        ),
                        "p": Style(margin: Margins.only(bottom: 8.sp)),
                        "strong": Style(fontWeight: FontWeight.bold),
                        "br": Style(margin: Margins.only(bottom: 4.sp)),
                      },
                    ),
                    SizedBox(height: 12.sp),
                  ],
                  // Scan solution button
                  if (widget.scanHistoryId != null &&
                      widget.scanHistoryId!.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScanSolution(
                                diseaseLabel: widget.diseaseLink!,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.sp),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                        ),
                        icon: Icon(Icons.medical_services, size: 16.sp),
                        label: Text(
                          'Xem giải pháp chi tiết',
                          style: AppTextStyles.s12Bold(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
