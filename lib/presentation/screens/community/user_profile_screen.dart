import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/services/token_storage_service.dart';
import 'package:se501_plantheon/data/datasources/post_remote_datasource.dart';
import 'package:se501_plantheon/domain/entities/post_entity.dart';
import 'package:se501_plantheon/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:se501_plantheon/presentation/screens/community/post_detail.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/acction_button.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/disease_block_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: LoadingIndicator()));
        }
        return BlocProvider(
          create: (context) => UserProfileBloc(
            remoteDataSource: PostRemoteDataSource(
              client: http.Client(),
              tokenStorage: TokenStorageService(prefs: snapshot.data!),
            ),
          )..add(FetchUserProfile(userId)),
          child: const _UserProfileView(),
        );
      },
    );
  }
}

class _UserProfileView extends StatelessWidget {
  const _UserProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, state) {
            if (state is UserProfileLoaded) {
              return Text(state.user.fullName, style: AppTextStyles.s16Bold());
            }
            return const Text('Trang cá nhân');
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is UserProfileError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.s14Regular(color: Colors.red),
                ),
              ),
            );
          } else if (state is UserProfileLoaded) {
            return CustomScrollView(
              slivers: [
                // User Info Header
                SliverToBoxAdapter(child: _buildUserHeader(state)),
                // Posts List
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: Text(
                      'Bài viết (${state.totalPosts})',
                      style: AppTextStyles.s16Bold(),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final post = state.posts[index];
                    return _buildPost(
                      context: context,
                      postIndex: index,
                      post: post,
                    );
                  }, childCount: state.posts.length),
                ),
                // Empty state
                if (state.posts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.sp),
                      child: Center(
                        child: Text(
                          'Chưa có bài viết nào',
                          style: AppTextStyles.s14Regular(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUserHeader(UserProfileLoaded state) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.sp),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50.sp,
            backgroundColor: Colors.green[200],
            backgroundImage: state.user.avatar.isNotEmpty
                ? NetworkImage(state.user.avatar)
                : null,
            child: state.user.avatar.isEmpty
                ? Text(
                    state.user.fullName.isNotEmpty
                        ? state.user.fullName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.s32SemiBold(color: Colors.white),
                  )
                : null,
          ),
          SizedBox(height: 16.sp),
          // Name
          Text(state.user.fullName, style: AppTextStyles.s20Bold()),
          SizedBox(height: 4.sp),
          // Username
          Text(
            '@${state.user.username}',
            style: AppTextStyles.s14Regular(color: Colors.grey[600]),
          ),
          SizedBox(height: 8.sp),
          // Member since
          Text(
            'Thành viên từ ${_formatDate(state.user.createdAt)}',
            style: AppTextStyles.s12Regular(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPost({
    required BuildContext context,
    required int postIndex,
    required PostEntity post,
  }) {
    final timeAgo = _formatTimeAgo(post.createdAt);
    final category = post.tags.isNotEmpty ? post.tags.first : 'Khác';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetail(postId: post.id)),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.sp),
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.sp),
            Row(
              children: [
                CircleAvatar(
                  radius: 20.sp,
                  backgroundColor: Colors.green[200],
                  child: Text(
                    post.fullName.isNotEmpty ? post.fullName[0] : '?',
                    style: AppTextStyles.s16Bold(color: Colors.white),
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
                            post.isMyPost ? 'Bạn' : post.fullName,
                            style: AppTextStyles.s16Bold(
                              color: post.isMyPost ? Colors.green : null,
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
                                context.read<UserProfileBloc>().add(
                                  DeletePostInProfile(post.id),
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
                    if (post.isMyPost)
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.sp),
              child: Text(post.content, style: AppTextStyles.s14Regular()),
            ),
            SizedBox(height: 8.sp),
            // Post images carousel
            if (post.imageLink != null && post.imageLink!.isNotEmpty)
              _buildImageCarousel(post.imageLink!),
            SizedBox(height: 8.sp),
            // Disease block
            DiseaseBlockWidget(
              diseaseLink: post.diseaseLink,
              diseaseName: post.diseaseName,
              diseaseDescription: post.diseaseDescription,
              diseaseSolution: post.diseaseSolution,
              diseaseImageLink: post.diseaseImageLink,
              scanHistoryId: post.scanHistoryId,
              postImageLinks: post.imageLink,
            ),
            SizedBox(height: 8.sp),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.sp),
              child: Row(
                children: [
                  SvgPicture.asset(
                    post.liked ? AppVectors.heartSolid : AppVectors.heart,
                    color: AppColors.red,
                    width: 16.sp,
                    height: 16.sp,
                  ),
                  SizedBox(width: 4.sp),
                  Text(
                    '${post.likeNumber} lượt thích',
                    style: AppTextStyles.s12Regular(),
                  ),
                  const Spacer(),
                  Text(
                    '${post.commentNumber} bình luận',
                    style: AppTextStyles.s12Regular(),
                  ),
                  SizedBox(width: 16.sp),
                  Text(
                    '${post.shareNumber} lượt chia sẻ',
                    style: AppTextStyles.s12Regular(),
                  ),
                ],
              ),
            ),
            // Action buttons
            Container(height: 1.sp, color: Colors.grey[200]),
            Row(
              children: [
                ActionButton(
                  iconVector: post.liked
                      ? AppVectors.heartSolid
                      : AppVectors.heart,
                  label: 'Thích',
                  onPressed: () {
                    context.read<UserProfileBloc>().add(
                      ToggleLikeInProfile(post.id),
                    );
                  },
                  iconColor: post.liked
                      ? AppColors.red
                      : AppColors.text_color_200,
                  textColor: post.liked
                      ? AppColors.red
                      : AppColors.text_color_400,
                ),
                Container(width: 1.sp, height: 40.sp, color: Colors.grey[200]),
                ActionButton(
                  iconVector: AppVectors.comment,
                  label: 'Bình luận',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetail(postId: post.id),
                      ),
                    );
                  },
                ),
                Container(width: 1.sp, height: 40.sp, color: Colors.grey[200]),
                ActionButton(
                  iconVector: AppVectors.share,
                  label: 'Chia sẻ',
                  onPressed: () {
                    _handleShare(
                      username: post.fullName,
                      content: post.content,
                      category: category,
                      postIndex: postIndex,
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

  Widget _buildImageCarousel(List<String> images) {
    final pageNotifier = ValueNotifier<int>(0);

    return Column(
      children: [
        SizedBox(
          height: 200.sp,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) => pageNotifier.value = index,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8.sp),
                child: Image.network(
                  images[index],
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image, size: 50.sp, color: Colors.grey),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: EdgeInsets.only(top: 8.sp),
            child: ValueListenableBuilder<int>(
              valueListenable: pageNotifier,
              builder: (context, currentPage, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.sp),
                      width: 8.sp,
                      height: 8.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentPage == index
                            ? Colors.green
                            : Colors.grey[300],
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

  void _handleShare({
    required String username,
    required String content,
    required String category,
    required int postIndex,
  }) {
    final shareText =
        'Bài viết của $username\n\n$content\n\nDanh mục: $category';
    Share.share(shareText);
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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
}
