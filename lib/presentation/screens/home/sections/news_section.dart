import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_state.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/disease_card.dart';
import 'package:se501_plantheon/presentation/screens/news/news.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_provider.dart';

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
                    child: const News(),
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
              if (state is NewsLoading || state is NewsInitial) {
                return const Center(child: LoadingIndicator());
              }

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

              if (state is NewsLoaded) {
                if (state.news.isEmpty) {
                  return Center(
                    child: Text(
                      'Hiện chưa có tin tức',
                      style: AppTextStyles.s14Regular(
                        color: AppColors.text_color_300,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.news.length,
                  itemBuilder: (context, index) {
                    final news = state.news[index];
                    final imageUrl = news.coverImageUrl.isNotEmpty
                        ? news.coverImageUrl
                        : 'assets/images/plants.jpg';

                    return Padding(
                      padding: EdgeInsets.only(right: 8.sp),
                      child: DiseaseWarningCard(
                        title: news.title,
                        description: news.description ?? '',
                        imagePath: imageUrl,
                        isNetworkImage: news.coverImageUrl.isNotEmpty,
                      ),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
