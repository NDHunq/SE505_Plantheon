import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/presentation/screens/community/user_profile_screen.dart';

import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/community/post_detail.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/acction_button.dart';
import 'package:se501_plantheon/presentation/screens/community/notification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/data/datasources/post_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/post_repository_impl.dart';
import 'package:se501_plantheon/presentation/bloc/community/community_bloc.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/create_post_modal.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/disease_block_widget.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_bloc.dart';
import 'package:se501_plantheon/data/repository/auth_repository_impl.dart';
import 'package:se501_plantheon/core/services/deep_link_service.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  // Controllers cho dialog post
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo số lượt thích ban đầu
    // likeCounts = {0: 28, 1: 15, 2: 42};
  }

  @override
  void dispose() {
    super.dispose();
  }

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
      )..add(FetchAllPosts()),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25.sp),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm ...',
                        border: InputBorder.none,
                        hintStyle: AppTextStyles.s14Regular(
                          color: AppColors.text_color_100,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  const Icon(Icons.search_rounded, color: Colors.grey),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  AppVectors.bell,
                  width: 24.sp,
                  height: 24.sp,
                  color: AppColors.primary_main,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Notification()),
                  );
                },
              ),
              SizedBox(width: 12.sp),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'community_fab',
            onPressed: () {
              CreatePostModal.show(context);
            },
            backgroundColor: AppColors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.sp),
              side: BorderSide(color: AppColors.orange_400, width: 5.sp),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 30.sp,
              color: AppColors.text_color_main,
            ),
          ),
          body: BlocBuilder<CommunityBloc, CommunityState>(
            builder: (context, state) {
              if (state is CommunityLoading) {
                return const Center(child: LoadingIndicator());
              } else if (state is CommunityError) {
                return Center(child: Text(state.message));
              } else if (state is CommunityLoaded) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 16.sp,
                    right: 16.sp,
                    bottom: 60.sp,
                  ),
                  child: ListView.builder(
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      return _buildPost(
                        context: context,
                        postIndex: index,
                        postId: post.id,
                        userId: post.userId,
                        username: post.fullName,
                        timeAgo: _formatTimeAgo(post.createdAt),
                        content: post.content,
                        category: post.tags.isNotEmpty
                            ? post.tags.first
                            : 'Khác',
                        imageUrl: post.avatar.isNotEmpty
                            ? post.avatar
                            : 'https://via.placeholder.com/400x300',
                        imageLink: post.imageLink,
                        diseaseLink: post.diseaseLink,
                        diseaseName: post.diseaseName,
                        diseaseDescription: post.diseaseDescription,
                        diseaseSolution: post.diseaseSolution,
                        diseaseImageLink: post.diseaseImageLink,
                        scanHistoryId: post.scanHistoryId,
                        likes: post.likeNumber,
                        isLiked: post.liked,
                        isMyPost: post.isMyPost,
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
        ),
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
                child: Image.network(
                  imageLinks[index],
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.sp),
                        color: Colors.grey[300],
                      ),
                      child: Icon(Icons.eco, size: 100.sp, color: Colors.green),
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
                      duration: const Duration(milliseconds: 300),
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
    required int postIndex,
    required String postId,
    required String userId,
    required String username,
    required String timeAgo,
    required String content,
    required String category,
    required String imageUrl, // Avatar
    required List<String>? imageLink, // Post images
    String? diseaseLink,
    String? diseaseName,
    String? diseaseDescription,
    String? diseaseSolution,
    String? diseaseImageLink,
    String? scanHistoryId,
    required int likes,
    required bool isLiked,
    required bool isMyPost,
    required int comments,
    required int shares,
  }) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetail(postId: postId)),
        );
        // Refresh posts when returning
        if (context.mounted) {
          context.read<CommunityBloc>().add(FetchAllPosts());
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.sp),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // spacing: 8, // This line causes an error, assuming it's meant to be a property of a different widget or removed.
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(userId: userId),
                      ),
                    );
                    // Refresh posts when returning
                    if (context.mounted) {
                      context.read<CommunityBloc>().add(FetchAllPosts());
                    }
                  },
                  child: CircleAvatar(
                    radius: 20.sp,
                    backgroundColor: Colors.green[200],
                    child: Text(
                      username.isNotEmpty ? username[0] : '?',
                      style: AppTextStyles.s16Bold(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isMyPost ? 'Bạn' : username,
                            style: AppTextStyles.s16Bold(
                              color: isMyPost ? Colors.green : null,
                            ),
                          ),
                          SizedBox(width: 4.sp),
                          Container(
                            padding: EdgeInsets.all(2.sp),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 12.sp,
                              color: Colors.white,
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
                    if (isMyPost)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Xóa bài viết',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined),
                          SizedBox(width: 8),
                          Text('Báo cáo'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.sp),
            Text(content, style: AppTextStyles.s14Regular()),
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
            Row(
              children: [
                SvgPicture.asset(
                  isLiked ? AppVectors.heartSolid : AppVectors.heart,
                  color: AppColors.red,
                  width: 16.sp,
                  height: 16.sp,
                ),
                SizedBox(width: 4.sp),
                Text('$likes lượt thích', style: AppTextStyles.s12Regular()),
                const Spacer(),
                Text('$comments bình luận', style: AppTextStyles.s12Regular()),
                SizedBox(width: 16.sp),
                Text('$shares lượt chia sẻ', style: AppTextStyles.s12Regular()),
              ],
            ),
            // Action buttons
            Container(height: 1.sp, color: Colors.grey[200]),
            Row(
              children: [
                ActionButton(
                  iconVector: isLiked
                      ? AppVectors.heartSolid
                      : AppVectors.heart,
                  label: 'Thích',
                  onPressed: () {
                    print('Debug: Like button pressed for post $postId');
                    context.read<CommunityBloc>().add(ToggleLikeEvent(postId));
                  },
                  iconColor: isLiked ? AppColors.red : AppColors.text_color_200,
                  textColor: isLiked ? AppColors.red : AppColors.text_color_400,
                ),
                Container(width: 1.sp, height: 40.sp, color: Colors.grey[200]),
                ActionButton(
                  iconVector: AppVectors.comment,
                  label: 'Bình luận',
                  onPressed: () {},
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
