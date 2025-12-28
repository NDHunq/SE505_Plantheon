import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/data/datasources/post_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/post_repository_impl.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_bloc.dart';
import 'package:se501_plantheon/data/repository/auth_repository_impl.dart';
import 'package:se501_plantheon/presentation/bloc/community/community_bloc.dart';
import 'package:se501_plantheon/presentation/screens/community/post_detail.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/acction_button.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/disease_block_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:se501_plantheon/core/services/deep_link_service.dart';

class MyPost extends StatelessWidget {
  const MyPost({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommunityBloc(
        postRepository: PostRepositoryImpl(
          remoteDataSource: PostRemoteDataSource(
            client: http.Client(),
            tokenStorage:
                (context.read<AuthBloc>().authRepository as AuthRepositoryImpl)
                    .tokenStorage,
          ),
        ),
      )..add(FetchMyPosts()),
      child: const _MyPostView(),
    );
  }
}

class _MyPostView extends StatelessWidget {
  const _MyPostView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(title: 'Bài viết của tôi'),
      backgroundColor: AppColors.white,
      body: BlocBuilder<CommunityBloc, CommunityState>(
        builder: (context, state) {
          if (state is CommunityLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is CommunityError) {
            return Center(child: Text(state.message));
          } else if (state is CommunityLoaded) {
            if (state.posts.isEmpty) {
              return Center(
                child: Text(
                  'Bạn chưa có bài viết nào.',
                  style: AppTextStyles.s16Regular(),
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
              child: ListView.builder(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return _buildPost(
                    context: context,
                    postId: post.id,
                    username: post.fullName,
                    timeAgo: _formatTimeAgo(post.createdAt),
                    content: post.content,
                    category: post.tags.isNotEmpty ? post.tags.first : 'Khác',
                    imageUrl: post.avatar.isNotEmpty ? post.avatar : '',
                    imageLink: post.imageLink,
                    diseaseLink: post.diseaseLink,
                    diseaseName: post.diseaseName,
                    diseaseDescription: post.diseaseDescription,
                    diseaseSolution: post.diseaseSolution,
                    diseaseImageLink: post.diseaseImageLink,
                    scanHistoryId: post.scanHistoryId,
                    likes: post.likeNumber,
                    isLiked: post.liked,
                    comments: post.commentNumber,
                    shares: post.shareNumber,
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  Widget _buildImageCarousel(List<String> imageLinks) {
    final ValueNotifier<int> currentPage = ValueNotifier<int>(0);
    final PageController pageController = PageController();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 200.sp,
          child: PageView.builder(
            controller: pageController,
            itemCount: imageLinks.length,
            onPageChanged: (index) {
              currentPage.value = index;
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12.sp),
                child: CachedNetworkImage(
                  imageUrl: imageLinks[index],
                  fit: BoxFit.contain,
                  width: double.infinity,
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      width: 40.sp,
                      height: 40.sp,
                      child: const LoadingIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.sp),
                        color: Colors.grey[300],
                      ),
                      child: Icon(
                        Icons.eco,
                        size: 100.sp,
                        color: AppColors.primary_main,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (imageLinks.length > 1)
          Padding(
            padding: EdgeInsets.only(top: 8.sp),
            child: ValueListenableBuilder<int>(
              valueListenable: currentPage,
              builder: (context, page, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    imageLinks.length,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 3.sp),
                      width: page == index ? 20.sp : 8.sp,
                      height: 8.sp,
                      decoration: BoxDecoration(
                        color: page == index
                            ? AppColors.primary_main
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4.sp),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPost({
    required BuildContext context,
    required String postId,
    required String username,
    required String timeAgo,
    required String content,
    required String category,
    required String imageUrl,
    required List<String>? imageLink,
    String? diseaseLink,
    String? diseaseName,
    String? diseaseDescription,
    String? diseaseSolution,
    String? diseaseImageLink,
    String? scanHistoryId,
    required int likes,
    required bool isLiked,
    required int comments,
    required int shares,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => PostDetail(postId: postId)),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.sp),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.sp,
                    backgroundColor: AppColors.primary_200,
                    backgroundImage:
                        imageUrl.isNotEmpty && !imageUrl.contains('placeholder')
                        ? NetworkImage(imageUrl)
                        : null,
                    child:
                        (imageUrl.isEmpty || imageUrl.contains('placeholder'))
                        ? Text(
                            username.isNotEmpty ? username[0] : '?',
                            style: AppTextStyles.s16Bold(color: Colors.white),
                          )
                        : null,
                  ),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Bạn',
                              style: AppTextStyles.s16Bold(
                                color: AppColors.primary_main,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$category • $timeAgo',
                          style: AppTextStyles.s12Regular(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (value) {
                      if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Xóa bài viết'),
                            content: const Text(
                              'Bạn có chắc muốn xóa bài viết này?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  context.read<CommunityBloc>().add(
                                    DeletePostEvent(postId),
                                  );
                                },
                                child: const Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppVectors.trash,
                              width: 22.sp,
                              height: 22.sp,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8.sp),
                            Text(
                              'Xóa bài viết',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.sp),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp),
              child: Text(content, style: AppTextStyles.s14Regular()),
            ),
            SizedBox(height: 8.sp),
            // Post images carousel
            if (imageLink != null && imageLink.isNotEmpty)
              _buildImageCarousel(imageLink),
            SizedBox(height: 8.sp),
            // Disease block
            DiseaseBlockWidget(
              diseaseLink: diseaseLink,
              diseaseName: diseaseName,
              diseaseDescription: diseaseDescription,
              diseaseSolution: diseaseSolution,
              diseaseImageLink: diseaseImageLink,
              scanHistoryId: scanHistoryId,
              postImageLinks: imageLink,
            ),
            SizedBox(height: 8.sp),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp),
              child: Row(
                children: [
                  SvgPicture.asset(
                    isLiked ? AppVectors.heartSolid : AppVectors.heart,
                    color: AppColors.red,
                    width: 16.sp,
                    height: 16.sp,
                  ),
                  SizedBox(width: 4.sp),
                  Text('$likes lượt thích', style: AppTextStyles.s12Regular()),
                  Spacer(),
                  Text(
                    '$comments bình luận',
                    style: AppTextStyles.s12Regular(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.sp),
            Container(height: 1.sp, color: Colors.grey[200]),
            SizedBox(height: 4.sp),

            Row(
              children: [
                ActionButton(
                  iconVector: isLiked
                      ? AppVectors.heartSolid
                      : AppVectors.heart,
                  label: 'Thích',
                  onPressed: () {
                    context.read<CommunityBloc>().add(ToggleLikeEvent(postId));
                  },
                  iconColor: isLiked ? AppColors.red : AppColors.text_color_200,
                  textColor: isLiked ? AppColors.red : AppColors.text_color_400,
                ),
                Container(width: 1.sp, height: 40.sp, color: Colors.grey[200]),
                ActionButton(
                  iconVector: AppVectors.comment,
                  label: 'Bình luận',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostDetail(postId: postId),
                      ),
                    );
                  },
                ),
                Container(width: 1.sp, height: 40.sp, color: Colors.grey[200]),
                ActionButton(
                  iconVector: AppVectors.share,
                  label: 'Chia sẻ',
                  onPressed: () {
                    DeepLinkService().copyLinkToClipboard(
                      context,
                      host: 'post',
                      params: {'id': postId},
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8.sp),
          ],
        ),
      ),
    );
  }
}
