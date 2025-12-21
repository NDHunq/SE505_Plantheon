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

class NewsSection extends StatefulWidget {
  const NewsSection({super.key});

  @override
  State<NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection> {
  final PageController _pageController = PageController(viewportFraction: 0.7);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: AppColors.primary_700,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 220.sp,
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

              return Column(
                children: [
                  Expanded(
                    child: Skeletonizer(
                      enabled: isLoading,
                      child: PageView.builder(
                        controller: _pageController,
                        padEnds: false,
                        itemCount: isLoading
                            ? displayNews.length
                            : displayNews.length + 1, // +1 for "See More" card
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
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

                          // Check if this is the "See More" card
                          if (index >= news.length) {
                            return Padding(
                              padding: EdgeInsets.only(right: 8.sp),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewsProvider(
                                        size: null,
                                        child: News(),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 200.sp,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.sp),
                                    border: Border.all(
                                      color: AppColors.primary_300,
                                      width: 1.sp,
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 48.sp,
                                        color: AppColors.primary_600,
                                      ),
                                      SizedBox(height: 12.sp),
                                      Text(
                                        'Xem thêm',
                                        style: AppTextStyles.s16Bold(
                                          color: AppColors.primary_600,
                                        ),
                                      ),
                                      SizedBox(height: 4.sp),
                                      Text(
                                        'Khám phá thêm tin tức',
                                        style: AppTextStyles.s12Regular(
                                          color: AppColors.primary_600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                      isFromFarmingTip: false,
                                      newsId: newsItem.id,
                                      repository: repo,
                                      fallbackTitle: newsItem.title,
                                      fallbackDescription:
                                          newsItem.description ?? '',
                                      fallbackImage: imageUrl,
                                      fallbackTag: newsItem.blogTagName ?? '',
                                      fallbackDate:
                                          newsItem.publishedAt ??
                                          newsItem.createdAt,
                                      fallbackContent:
                                          newsItem.description ?? '',
                                    ),
                                  ),
                                );
                              },
                              child: BlogCard(
                                title: newsItem.title,
                                description: newsItem.description ?? '',
                                imagePath: imageUrl,
                                isNetworkImage:
                                    newsItem.coverImageUrl.isNotEmpty,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (!isLoading && displayNews.isNotEmpty) ...[
                    SizedBox(height: 8.sp),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        displayNews.length + 1, // +1 for see more indicator
                        (index) => AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4.sp),
                          width: _currentPage == index ? 20.sp : 8.sp,
                          height: 8.sp,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.primary_600
                                : AppColors.text_color_100,
                            borderRadius: BorderRadius.circular(4.sp),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
