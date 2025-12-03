import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/report_button.dart';
import 'package:share_plus/share_plus.dart';
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

  void _handleShare({
    required String username,
    required String content,
    required String category,
    required int postIndex,
  }) {
    String shareText =
        'Bài viết từ $username\n\n$content\n\n#$category\n\nChia sẻ từ Plantheon';

    Share.share(shareText, subject: 'Bài viết từ Plantheon').then((_) {
      // Cập nhật số lượt chia sẻ
      // Note: Optimistic update for share count is not fully implemented in BLoC yet,
      // but we can keep this local state update if 'posts' list was used.
      // However, since we use BLoC, this local 'posts' list might not be the source of truth.
      // For now, we'll just share.
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommunityBloc(
        postRepository: PostRepositoryImpl(
          remoteDataSource: PostRemoteDataSource(client: http.Client()),
        ),
      )..add(FetchUserPosts('6937d944-c8d9-49b7-94c7-b281c23dbd31')),
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

  Widget _buildPost({
    required BuildContext context,
    required int postIndex,
    required String postId,
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
    required int comments,
    required int shares,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetail(postId: postId)),
        );
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
                CircleAvatar(
                  radius: 20.sp,
                  backgroundColor: Colors.green[200],
                  child: Text(
                    username[0],
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
                          Text(username, style: AppTextStyles.s16Bold()),
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
                ReportButton(context: context),
              ],
            ),
            SizedBox(height: 8.sp),
            Text(content, style: AppTextStyles.s14Regular()),
            SizedBox(height: 8.sp),
            // Post image
            if (imageLink != null && imageLink.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 200.sp,
                child: Image.network(
                  imageLink.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.sp),
                        color: Colors.grey[300],
                      ),
                      child: Icon(Icons.eco, size: 100.sp, color: Colors.green),
                    );
                  },
                ),
              ),
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
                    _handleShare(
                      username: username,
                      content: content,
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
}
