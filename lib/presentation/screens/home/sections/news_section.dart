import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_state.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/blog_card.dart';
import 'package:se501_plantheon/presentation/screens/news/news.dart';
import 'package:se501_plantheon/presentation/screens/news/detail_news.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_provider.dart';
import 'package:se501_plantheon/data/repository/news_repository_impl.dart';

class NewsSection extends StatelessWidget {
  const NewsSection({super.key});

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
                MaterialPageRoute(
                  builder: (context) => NewsProvider(
                    size: null, // fetch all for full screen
                    child: News(),
                  ),
                ),
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
          child: BlocBuilder<NewsBloc, NewsState>(
            builder: (context, state) {
              final isLoading = state is NewsLoading || state is NewsInitial;

              if (state is NewsError) {
                return Center(
                  child: Text(
                    'Không thể tải tin tức',
                    style: AppTextStyles.s14Regular(
                      color: AppColors.text_color_300,
                    ),
                  ),
                );
              }

              final news = state is NewsLoaded ? state.news : [];

              if (!isLoading && news.isEmpty) {
                return Center(
                  child: Text(
                    'Hiện chưa có tin tức',
                    style: AppTextStyles.s14Regular(
                      color: AppColors.text_color_300,
                    ),
                  ),
                );
              }

              // Show skeleton or real data
              final displayNews = isLoading
                  ? List.generate(3, (index) => null) // 3 skeleton items
                  : news;

              return Skeletonizer(
                enabled: isLoading,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayNews.length,
                  itemBuilder: (context, index) {
                    if (isLoading) {
                      // Skeleton card
                      return Padding(
                        padding: EdgeInsets.only(right: 8.sp),
                        child: const BlogCard(
                          title: 'News Title Loading',
                          description: 'Description loading text here',
                          imagePath: '',
                          isNetworkImage: false,
                        ),
                      );
                    }

                    final newsItem = news[index];
                    final imageUrl = newsItem.coverImageUrl.isNotEmpty
                        ? newsItem.coverImageUrl
                        : 'assets/images/plants.jpg';

                    return Padding(
                      padding: EdgeInsets.only(right: 8.sp),
                      child: GestureDetector(
                        onTap: () {
                          final repo = context.read<NewsRepositoryImpl>();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailNews(
                                newsId: newsItem.id,
                                repository: repo,
                                fallbackTitle: newsItem.title,
                                fallbackDescription: newsItem.description ?? '',
                                fallbackImage: imageUrl,
                                fallbackTag: newsItem.blogTagName ?? '',
                                fallbackDate:
                                    newsItem.publishedAt ?? newsItem.createdAt,
                                fallbackContent: newsItem.description ?? '',
                                isFromFarmingTip: false,
                              ),
                            ),
                          );
                        },
                        child: BlogCard(
                          title: newsItem.title,
                          description: newsItem.description ?? '',
                          imagePath: imageUrl,
                          isNetworkImage: newsItem.coverImageUrl.isNotEmpty,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
