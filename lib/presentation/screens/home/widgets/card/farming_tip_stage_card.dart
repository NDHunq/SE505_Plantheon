import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:intl/intl.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/domain/entities/sub_guide_stage_entity.dart';
import 'package:se501_plantheon/presentation/bloc/guide_stage_detail/guide_stage_detail_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/guide_stage_detail/guide_stage_detail_event.dart';
import 'package:se501_plantheon/presentation/bloc/guide_stage_detail/guide_stage_detail_state.dart';
import 'package:se501_plantheon/presentation/screens/news/detail_news.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_provider.dart';
import 'package:se501_plantheon/data/repository/news_repository_impl.dart';

class FarmingTipStageCard extends StatefulWidget {
  final String stageId;
  final String imageUrl;
  final String stageLabel;
  final String stageDescription;
  final String stageTime;
  final bool isNow;
  final DateTime sowingDate;

  const FarmingTipStageCard({
    super.key,
    required this.stageId,
    required this.imageUrl,
    required this.stageLabel,
    required this.stageDescription,
    required this.stageTime,
    required this.sowingDate,
    this.isNow = false,
  });

  @override
  State<FarmingTipStageCard> createState() => _FarmingTipStageCardState();
}

class _FarmingTipStageCardState extends State<FarmingTipStageCard> {
  bool isCollapsed = true;
  bool _hasFetched = false;

  void _toggleCollapse() {
    setState(() {
      isCollapsed = !isCollapsed;
    });

    if (!isCollapsed && !_hasFetched) {
      context.read<GuideStageDetailBloc>().add(
        FetchGuideStageDetailEvent(guideStageId: widget.stageId),
      );
      _hasFetched = true;
    }
  }

  String _formatSubStageTime(SubGuideStageEntity subStage) {
    final formatter = DateFormat('dd/MM/yyyy');
    final startDate = widget.sowingDate.add(
      Duration(days: subStage.startDayOffset),
    );
    final endDate = widget.sowingDate.add(
      Duration(days: subStage.endDayOffset),
    );
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCollapse,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isNow ? AppColors.primary_300 : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: AppColors.text_color_200, width: 1.sp),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    imageBuilder: (context, imageProvider) => ClipRRect(
                      borderRadius: BorderRadius.circular(8.sp),
                      child: Image(
                        image: imageProvider,
                        width: 72.sp,
                        height: 72.sp,
                        fit: BoxFit.cover,
                      ),
                    ),
                    placeholder: (context, url) => ClipRRect(
                      borderRadius: BorderRadius.circular(8.sp),
                      child: Container(
                        width: 60.sp,
                        height: 60.sp,
                        color: AppColors.primary_50,
                        child: Center(
                          child: SizedBox(
                            width: 16.sp,
                            height: 16.sp,
                            child: LoadingIndicator(),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => ClipRRect(
                      borderRadius: BorderRadius.circular(8.sp),
                      child: Container(
                        width: 60.sp,
                        height: 60.sp,
                        color: AppColors.primary_50,
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.primary_400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.sp,
                              vertical: 2.sp,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.sp),
                              border: Border.all(
                                color: widget.isNow
                                    ? AppColors.white
                                    : AppColors.text_color_200,
                                width: 1.sp,
                              ),
                            ),
                            child: Text(
                              widget.stageLabel,
                              style: AppTextStyles.s12Medium(
                                color: widget.isNow
                                    ? AppColors.white
                                    : AppColors.text_color_200,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.sp),
                          Text(
                            widget.stageDescription,
                            style: AppTextStyles.s14Medium(
                              color: widget.isNow
                                  ? AppColors.white
                                  : AppColors.text_color_200,
                            ),
                          ),
                          SizedBox(height: 4.sp),
                          Text(
                            widget.stageTime,
                            style: AppTextStyles.s16Bold(
                              color: widget.isNow
                                  ? AppColors.white
                                  : AppColors.text_color_400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isCollapsed ? 0.0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.isNow
                          ? AppColors.white
                          : AppColors.text_color_50,
                    ),
                  ),
                ],
              ),
            ),
            if (!isCollapsed)
              BlocBuilder<GuideStageDetailBloc, GuideStageDetailState>(
                builder: (context, state) {
                  if (state is GuideStageDetailLoading) {
                    return const Center(child: LoadingIndicator());
                  }
                  if (state is GuideStageDetailError) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp),
                      child: Text(
                        'Không tải được chi tiết: ${state.message}',
                        style: AppTextStyles.s14Regular(color: Colors.red),
                      ),
                    );
                  }
                  if (state is GuideStageDetailLoaded) {
                    if (state.detail.subGuideStages.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.sp),
                        child: Text(
                          'Chưa có dữ liệu chi tiết cho giai đoạn này.',
                          style: AppTextStyles.s14Regular(
                            color: AppColors.text_color_200,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: state.detail.subGuideStages
                          .map(
                            (sub) => _SubGuideStageSection(
                              subStage: sub,
                              timeRange: _formatSubStageTime(sub),
                            ),
                          )
                          .toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SubGuideStageSection extends StatelessWidget {
  final SubGuideStageEntity subStage;
  final String timeRange;

  const _SubGuideStageSection({
    required this.subStage,
    required this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DottedLine(
            dashLength: 6.sp,
            dashGapLength: 4.sp,
            lineThickness: 1.sp,
            dashColor: AppColors.text_color_200,
          ),
          SizedBox(height: 8.sp),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subStage.title,
                  style: AppTextStyles.s16SemiBold(
                    color: AppColors.primary_700,
                  ),
                ),
                Text(
                  timeRange,
                  style: AppTextStyles.s14Regular(
                    color: AppColors.text_color_400,
                  ),
                ),
                SizedBox(height: 8.sp),
                SizedBox(
                  height: 170.sp,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: subStage.blogs.length,
                    separatorBuilder: (context, index) => SizedBox(width: 8.sp),
                    itemBuilder: (context, index) => _BlogCard(
                      blogId: subStage.blogs[index].id,
                      title: subStage.blogs[index].title,
                      content: subStage.blogs[index].content,
                      coverImageUrl: subStage.blogs[index].coverImageUrl,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.sp),
        ],
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  final String blogId;
  final String title;
  final String content;
  final String coverImageUrl;

  const _BlogCard({
    required this.blogId,
    required this.title,
    required this.content,
    required this.coverImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final imageUrl = coverImageUrl.isNotEmpty
            ? coverImageUrl
            : 'assets/images/plants.jpg';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsProvider(
              child: Builder(
                builder: (context) => DetailNews(
                  newsId: blogId,
                  repository: context.read<NewsRepositoryImpl>(),
                  fallbackTitle: title,
                  fallbackDescription: content,
                  fallbackImage: imageUrl,
                  fallbackTag: '',
                  fallbackDate: DateTime.now(),
                  fallbackContent: content,
                  isFromFarmingTip: true,
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        width: 140.sp,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(color: AppColors.text_color_50, width: 1.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140.sp,
              height: 90.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.sp),
                image: coverImageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(coverImageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: coverImageUrl.isEmpty ? AppColors.primary_50 : null,
              ),
              child: coverImageUrl.isEmpty
                  ? Icon(
                      Icons.image_not_supported,
                      color: AppColors.primary_400,
                    )
                  : null,
            ),
            Padding(
              padding: EdgeInsets.all(8.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.sp,
                      vertical: 4.sp,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary_100,
                      borderRadius: BorderRadius.circular(20.sp),
                    ),
                    child: Text(
                      title,
                      style: AppTextStyles.s12Medium(
                        color: AppColors.primary_700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 4.sp),
                  Text(
                    content,
                    style: AppTextStyles.s10Regular(
                      color: AppColors.text_color_400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
