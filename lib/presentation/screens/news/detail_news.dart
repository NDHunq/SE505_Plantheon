import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/domain/entities/news_entity.dart';
import 'package:se501_plantheon/domain/usecases/news/get_news_detail.dart';
import 'package:se501_plantheon/presentation/bloc/news_detail/news_detail_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/news_detail/news_detail_event.dart';
import 'package:se501_plantheon/presentation/bloc/news_detail/news_detail_state.dart';
import 'package:se501_plantheon/data/repository/news_repository_impl.dart';

class DetailNews extends StatelessWidget {
  final String newsId;
  final NewsRepositoryImpl repository;
  final String? fallbackTitle;
  final String? fallbackDescription;
  final String? fallbackImage;
  final String? fallbackTag;
  final DateTime? fallbackDate;
  final String? fallbackContent;

  const DetailNews({
    super.key,
    required this.newsId,
    required this.repository,
    this.fallbackTitle,
    this.fallbackDescription,
    this.fallbackImage,
    this.fallbackTag,
    this.fallbackDate,
    this.fallbackContent,
  });

  String _formatDateUtcPlus7(DateTime? dt) {
    if (dt == null) return '';
    // normalize to UTC then apply +7 offset
    final adjusted = dt.toUtc().add(const Duration(hours: 7));
    return DateFormat('dd/MM/yyyy').format(adjusted);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NewsDetailBloc>(
      create: (context) =>
          NewsDetailBloc(getNewsDetail: GetNewsDetail(repository: repository))
            ..add(FetchNewsDetailEvent(id: newsId)),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: BasicAppbar(
          title: 'Chi tiết tin tức',
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 8.sp),
              child: InkWell(
                onTap: () {},
                child: Icon(
                  Icons.share_outlined,
                  size: 24.sp,
                  color: AppColors.primary_600,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<NewsDetailBloc, NewsDetailState>(
          builder: (context, state) {
            if (state is NewsDetailLoading || state is NewsDetailInitial) {
              return const Center(child: LoadingIndicator());
            }

            if (state is NewsDetailError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Text(
                    'Không thể tải bài viết',
                    style: AppTextStyles.s14Regular(
                      color: AppColors.text_color_300,
                    ),
                  ),
                ),
              );
            }

            final NewsEntity news = state is NewsDetailLoaded
                ? state.news
                : NewsEntity(
                    id: newsId,
                    title: fallbackTitle ?? '',
                    description: fallbackDescription,
                    content: fallbackContent,
                    blogTagId: '',
                    blogTagName: fallbackTag,
                    coverImageUrl: fallbackImage ?? '',
                    status: '',
                    publishedAt: fallbackDate,
                    createdAt: fallbackDate ?? DateTime.now(),
                    updatedAt: fallbackDate ?? DateTime.now(),
                    userId: '',
                    fullName: '',
                    avatar: '',
                  );

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section with Title and Category
                  Container(
                    padding: EdgeInsets.all(16.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          news.title,
                          style: AppTextStyles.s24Bold(
                            color: AppColors.text_color_main,
                          ),
                        ),
                        SizedBox(height: 8.sp),
                        // Date and author
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.sp,
                                vertical: 2.sp,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary_50,
                                border: Border.all(
                                  color: AppColors.primary_100,
                                  width: 1.sp,
                                ),
                                borderRadius: BorderRadius.circular(16.sp),
                              ),
                              child: Text(
                                news.blogTagName ?? 'Tin tức',
                                style: AppTextStyles.s12Medium(
                                  color: AppColors.primary_700,
                                ),
                              ),
                            ),
                            SizedBox(width: 16.sp),

                            Icon(
                              Icons.access_time,
                              size: 14.sp,
                              color: AppColors.text_color_200,
                            ),
                            SizedBox(width: 4.sp),
                            Text(
                              _formatDateUtcPlus7(
                                news.publishedAt ?? news.createdAt,
                              ),
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
                              news.fullName.isNotEmpty
                                  ? news.fullName
                                  : 'Tác giả',
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
                        image: news.coverImageUrl.isNotEmpty
                            ? NetworkImage(news.coverImageUrl)
                            : const AssetImage('assets/images/plants.jpg')
                                  as ImageProvider,
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
                        if ((news.description ?? '').isNotEmpty) ...[
                          Text(
                            news.description ?? '',
                            style: AppTextStyles.s16Regular(
                              color: AppColors.text_color_400,
                            ),
                          ),
                          SizedBox(height: 16.sp),
                        ],

                        // Markdown Content
                        if ((news.content ?? '').isNotEmpty) ...[
                          MarkdownBody(
                            data: news.content ?? '',
                            styleSheet: MarkdownStyleSheet(
                              h1: AppTextStyles.s16Bold(
                                color: AppColors.primary_700,
                              ),
                              h2: AppTextStyles.s16Bold(
                                color: AppColors.primary_600,
                              ),
                              h3: AppTextStyles.s16Bold(
                                color: AppColors.primary_600,
                              ),
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
                                backgroundColor: AppColors.text_color_50
                                    .withOpacity(0.3),
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
                          style: AppTextStyles.s16Bold(
                            color: AppColors.primary_700,
                          ),
                        ),
                        SizedBox(height: 12.sp),
                        Wrap(
                          spacing: 8.sp,
                          runSpacing: 8.sp,
                          children: [
                            _buildTopicChip(news.blogTagName ?? 'Tin tức'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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
