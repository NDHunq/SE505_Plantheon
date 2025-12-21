import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_state.dart';
import 'package:se501_plantheon/presentation/bloc/news_tag/news_tag_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/news_tag/news_tag_state.dart';
import 'package:se501_plantheon/presentation/screens/news/detail_news.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/blog_card.dart';
import 'package:se501_plantheon/presentation/screens/news/widgets/horizontal_news_card.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_event.dart';
import 'package:se501_plantheon/presentation/bloc/news_tag/news_tag_event.dart';
import 'package:se501_plantheon/domain/entities/news_entity.dart';
import 'package:se501_plantheon/data/repository/news_repository_impl.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _carouselController = PageController(
    viewportFraction: 0.85,
  );
  String _selectedFilter = 'Tất cả';
  String _selectedSort = 'Mới nhất';
  String _tempSelectedSort = 'Mới nhất';
  int _currentCarouselPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // ensure data fetched if provider not triggered yet
    context.read<NewsBloc>().add(FetchNewsEvent());
    context.read<NewsTagBloc>().add(FetchNewsTagsEvent());
  }

  List<NewsEntity> _filterNews(
    List<NewsEntity> news,
    String selectedFilter,
    String searchText,
  ) {
    return news.where((item) {
      final matchesTag = selectedFilter == 'Tất cả'
          ? true
          : (item.blogTagName?.toLowerCase() ?? '') ==
                selectedFilter.toLowerCase();
      final matchesSearch = searchText.isEmpty
          ? true
          : (item.title.toLowerCase().contains(searchText.toLowerCase()) ||
                (item.description ?? '').toLowerCase().contains(
                  searchText.toLowerCase(),
                ));
      return matchesTag && matchesSearch;
    }).toList();
  }

  List<NewsEntity> _sortNews(List<NewsEntity> news, String selectedSort) {
    final sorted = List<NewsEntity>.from(news);
    if (selectedSort == 'Mới nhất') {
      sorted.sort(
        (a, b) => (b.publishedAt ?? b.createdAt).compareTo(
          a.publishedAt ?? a.createdAt,
        ),
      );
    } else if (selectedSort == 'Cũ nhất') {
      sorted.sort(
        (a, b) => (a.publishedAt ?? a.createdAt).compareTo(
          b.publishedAt ?? b.createdAt,
        ),
      );
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: BasicAppbar(
        title: 'Tin tức',
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              AppVectors.filter,
              color: AppColors.primary_700,
              height: 24.sp,
              width: 24.sp,
            ),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8.sp,
                  offset: Offset(0, 2.sp),
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              decoration: BoxDecoration(
                color: AppColors.text_color_50.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24.sp),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm tin tức...',
                  border: InputBorder.none,
                  hintStyle: AppTextStyles.s14Regular(
                    color: AppColors.text_color_100,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.text_color_200,
                    size: 20.sp,
                  ),
                ),
                style: AppTextStyles.s14Regular(),
              ),
            ),
          ),

          // Filter Chips
          Container(
            height: 50.sp,
            padding: EdgeInsets.symmetric(vertical: 8.sp),
            child: BlocBuilder<NewsTagBloc, NewsTagState>(
              builder: (context, tagState) {
                if (tagState is NewsTagLoading || tagState is NewsTagInitial) {
                  return const Center(child: LoadingIndicator());
                }

                if (tagState is NewsTagError) {
                  return Center(
                    child: Text(
                      'Không tải được danh mục',
                      style: AppTextStyles.s14Regular(
                        color: AppColors.text_color_300,
                      ),
                    ),
                  );
                }

                final tags = <String>['Tất cả'];
                if (tagState is NewsTagLoaded) {
                  tags.addAll(tagState.tags.map((e) => e.name));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.sp),
                  itemCount: tags.length,
                  itemBuilder: (context, index) {
                    final filter = tags[index];
                    final isSelected = filter == _selectedFilter;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.sp),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                          // log filtered news
                          final newsState = context.read<NewsBloc>().state;
                          if (newsState is NewsLoaded) {
                            final filtered = _filterNews(
                              newsState.news,
                              filter,
                              _searchController.text,
                            );
                            // ignore: avoid_print
                            print(
                              '📰 Filter "$filter": ${filtered.length} items',
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.sp,
                            vertical: 8.sp,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary_main
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(20.sp),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary_main
                                  : AppColors.text_color_50,
                              width: 1.sp,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                Icon(
                                  Icons.check,
                                  size: 16.sp,
                                  color: AppColors.white,
                                ),
                                SizedBox(width: 6.sp),
                              ],
                              Text(
                                filter,
                                style: AppTextStyles.s12Medium(
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.text_color_400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Content - Carousel + List
          Expanded(
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
                  final filteredPosts = _filterNews(
                    state.news,
                    _selectedFilter,
                    _searchController.text,
                  );
                  final sortedPosts = _sortNews(filteredPosts, _selectedSort);

                  if (sortedPosts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 64.sp,
                            color: AppColors.text_color_100,
                          ),
                          SizedBox(height: 16.sp),
                          Text(
                            'Không có bài viết nào',
                            style: AppTextStyles.s16Medium(
                              color: AppColors.text_color_200,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Split posts into carousel (first 3) and list (rest)
                  final carouselPosts = sortedPosts.take(3).toList();
                  final listPosts = sortedPosts.length > 3
                      ? sortedPosts.sublist(3)
                      : <NewsEntity>[];

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Carousel for first 3 posts
                        if (carouselPosts.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.sp,
                              vertical: 8.sp,
                            ),
                            child: Text(
                              'Nổi bật',
                              style: AppTextStyles.s16Bold(
                                color: AppColors.text_color_400,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 220.sp,
                            child: Column(
                              children: [
                                Expanded(
                                  child: PageView.builder(
                                    controller: _carouselController,
                                    itemCount: carouselPosts.length,
                                    padEnds: false,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentCarouselPage = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      final post = carouselPosts[index];
                                      final imageUrl =
                                          post.coverImageUrl.isNotEmpty
                                          ? post.coverImageUrl
                                          : 'assets/images/plants.jpg';
                                      // Custom padding based on index
                                      EdgeInsets itemPadding;
                                      if (index == 0) {
                                        itemPadding = EdgeInsets.only(
                                          left: 16.sp,
                                          right: 8.sp,
                                        );
                                      } else if (index ==
                                          carouselPosts.length - 1) {
                                        itemPadding = EdgeInsets.only(
                                          left: 8.sp,
                                          right: 16.sp,
                                        );
                                      } else {
                                        itemPadding = EdgeInsets.symmetric(
                                          horizontal: 8.sp,
                                        );
                                      }

                                      return Padding(
                                        padding: itemPadding,
                                        child: GestureDetector(
                                          onTap: () {
                                            final repo = context
                                                .read<NewsRepositoryImpl>();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailNews(
                                                      newsId: post.id,
                                                      repository: repo,
                                                      fallbackTitle: post.title,
                                                      fallbackDescription:
                                                          post.description ??
                                                          '',
                                                      fallbackImage: imageUrl,
                                                      fallbackTag:
                                                          post.blogTagName ??
                                                          '',
                                                      fallbackDate:
                                                          post.publishedAt ??
                                                          post.createdAt,
                                                      fallbackContent:
                                                          post.description ??
                                                          '',
                                                    ),
                                              ),
                                            );
                                          },
                                          child: BlogCard(
                                            title: post.title,
                                            description: post.description ?? '',
                                            imagePath: imageUrl,
                                            isNetworkImage:
                                                post.coverImageUrl.isNotEmpty,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 8.sp),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    carouselPosts.length,
                                    (index) => AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 4.sp,
                                      ),
                                      width: _currentCarouselPage == index
                                          ? 20.sp
                                          : 8.sp,
                                      height: 8.sp,
                                      decoration: BoxDecoration(
                                        color: _currentCarouselPage == index
                                            ? AppColors.primary_600
                                            : AppColors.text_color_100,
                                        borderRadius: BorderRadius.circular(
                                          4.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Section 2: Vertical list for remaining posts
                        if (listPosts.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.sp,
                              vertical: 8.sp,
                            ),
                            child: Text(
                              'Tất cả tin tức',
                              style: AppTextStyles.s16Bold(
                                color: AppColors.text_color_400,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.sp),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: listPosts.length,
                              itemBuilder: (context, index) {
                                final post = listPosts[index];
                                final imageUrl = post.coverImageUrl.isNotEmpty
                                    ? post.coverImageUrl
                                    : 'assets/images/plants.jpg';
                                return HorizontalNewsCard(
                                  title: post.title,
                                  description: post.description ?? '',
                                  imagePath: imageUrl,
                                  isNetworkImage: post.coverImageUrl.isNotEmpty,
                                  showDivider: index != listPosts.length - 1,
                                  onTap: () {
                                    final repo = context
                                        .read<NewsRepositoryImpl>();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailNews(
                                          newsId: post.id,
                                          repository: repo,
                                          fallbackTitle: post.title,
                                          fallbackDescription:
                                              post.description ?? '',
                                          fallbackImage: imageUrl,
                                          fallbackTag: post.blogTagName ?? '',
                                          fallbackDate:
                                              post.publishedAt ??
                                              post.createdAt,
                                          fallbackContent:
                                              post.description ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],

                        SizedBox(height: 16.sp),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    _tempSelectedSort = _selectedSort;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.sp),
                  topRight: Radius.circular(20.sp),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8.sp),
                      width: 40.sp,
                      height: 4.sp,
                      decoration: BoxDecoration(
                        color: AppColors.text_color_100,
                        borderRadius: BorderRadius.circular(2.sp),
                      ),
                    ),

                    // Header with title and clear button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bộ lọc',
                          style: AppTextStyles.s20Bold(
                            color: AppColors.primary_main,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _tempSelectedSort = 'Mới nhất';
                            });
                          },
                          child: Text(
                            'Làm sạch',
                            style: AppTextStyles.s14Medium(
                              color: AppColors.primary_main,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.sp),

                    // Sort by section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sắp xếp theo',
                        style: AppTextStyles.s16Bold(),
                      ),
                    ),

                    SizedBox(height: 12.sp),

                    // Sort buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildSortButton(
                            'Mới nhất',
                            _tempSelectedSort == 'Mới nhất',
                            () {
                              setModalState(() {
                                _tempSelectedSort = 'Mới nhất';
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        Expanded(
                          child: _buildSortButton(
                            'Cũ nhất',
                            _tempSelectedSort == 'Cũ nhất',
                            () {
                              setModalState(() {
                                _tempSelectedSort = 'Cũ nhất';
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        Expanded(
                          child: _buildSortButton(
                            'Phổ biến nhất',
                            _tempSelectedSort == 'Phổ biến nhất',
                            () {
                              setModalState(() {
                                _tempSelectedSort = 'Phổ biến nhất';
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.sp),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.sp),
                              side: BorderSide(
                                color: AppColors.primary_main,
                                width: 1.sp,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                            ),
                            child: Text(
                              'Hủy bỏ',
                              style: AppTextStyles.s16Medium(
                                color: AppColors.primary_main,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedSort = _tempSelectedSort;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.sp),
                              backgroundColor: AppColors.primary_main,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                            ),
                            child: Text(
                              'Áp dụng',
                              style: AppTextStyles.s16Bold(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.sp),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.sp),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.text_color_50 : AppColors.white,
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(color: AppColors.text_color_50, width: 1.sp),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.s12Medium(color: AppColors.text_color_400),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
