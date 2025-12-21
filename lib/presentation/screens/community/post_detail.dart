import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/data/datasources/post_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/post_repository_impl.dart';
import 'package:se501_plantheon/domain/entities/comment_entity.dart';
import 'package:se501_plantheon/presentation/bloc/post_detail/post_detail_bloc.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/acction_button.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/disease_block_widget.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/presentation/bloc/auth/auth_bloc.dart';
import 'package:se501_plantheon/presentation/screens/community/user_profile_screen.dart';
import 'package:se501_plantheon/data/repository/auth_repository_impl.dart';
import 'package:se501_plantheon/core/services/deep_link_service.dart';

import 'package:toastification/toastification.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/report_modal.dart';

class PostDetail extends StatelessWidget {
  final String postId;

  const PostDetail({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostDetailBloc(
        postRepository: PostRepositoryImpl(
          remoteDataSource: PostRemoteDataSource(
            client: http.Client(),
            tokenStorage:
                (context.read<AuthBloc>().authRepository as AuthRepositoryImpl)
                    .tokenStorage,
          ),
        ),
      )..add(FetchPostDetail(postId)),
      child: PostDetailView(postId: postId),
    );
  }
}

class PostDetailView extends StatefulWidget {
  final String postId;
  const PostDetailView({super.key, required this.postId});

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final TextEditingController _commentController = TextEditingController();

  // Reply functionality
  bool isReplying = false;
  String replyingToUsername = '';
  String? replyingToCommentId;

  // Expanded replies state
  final Set<String> _expandedComments = {};

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: SvgPicture.asset(
            AppVectors.arrowBack,
            width: 28.sp,
            height: 28.sp,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: BlocBuilder<PostDetailBloc, PostDetailState>(
          builder: (context, state) {
            if (state is PostDetailLoaded) {
              return Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProfileScreen(userId: state.post.userId),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20.sp,
                      backgroundColor: Colors.green[200],
                      backgroundImage: state.post.avatar.isNotEmpty
                          ? NetworkImage(state.post.avatar)
                          : null,
                      child: state.post.avatar.isEmpty
                          ? Text(
                              state.post.fullName.isNotEmpty
                                  ? state.post.fullName[0]
                                  : '?',
                              style: AppTextStyles.s16Bold(color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfileScreen(
                                      userId: state.post.userId,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                state.post.isMyPost
                                    ? 'Bạn'
                                    : state.post.fullName,
                                style: AppTextStyles.s16Bold(
                                  color: state.post.isMyPost
                                      ? Colors.green
                                      : Colors.black, // Explicit black
                                ),
                              ),
                            ),
                            SizedBox(width: 4.sp),
                            Container(
                              padding: EdgeInsets.all(2.sp),
                              decoration: BoxDecoration(
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
                          '${state.post.tags.isNotEmpty ? state.post.tags.first : 'General'} • ${_formatTimeAgo(state.post.createdAt)}',
                          style: AppTextStyles.s12Regular(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        actions: [
          BlocBuilder<PostDetailBloc, PostDetailState>(
            builder: (context, state) {
              if (state is PostDetailLoaded) {
                return PopupMenuButton<String>(
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
                              onPressed: () async {
                                Navigator.pop(ctx);
                                // Call delete API directly here since we need to navigate back
                                try {
                                  final repo = context
                                      .read<PostDetailBloc>()
                                      .postRepository;
                                  await repo.deletePost(state.post.id);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    toastification.show(
                                      context: context,
                                      type: ToastificationType.error,
                                      style: ToastificationStyle.flat,
                                      title: Text('Lỗi: $e'),
                                      autoCloseDuration: const Duration(
                                        seconds: 3,
                                      ),
                                      alignment: Alignment.bottomCenter,
                                      showProgressBar: true,
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                'Xóa',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (value == 'report') {
                      ReportModal.show(context, state.post.id, 'POST');
                    }
                  },
                  itemBuilder: (ctx) => [
                    if (state.post.isMyPost)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
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
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            AppVectors.report,
                            width: 20.sp,
                            height: 20.sp,
                            color: AppColors.text_color_400,
                          ),
                          SizedBox(width: 8.sp),
                          Text('Báo cáo'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<PostDetailBloc, PostDetailState>(
        builder: (context, state) {
          if (state is PostDetailLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is PostDetailError) {
            return Center(child: Text(state.message));
          } else if (state is PostDetailLoaded) {
            final post = state.post;
            return Padding(
              padding: EdgeInsets.all(16.sp),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.content, style: AppTextStyles.s14Regular()),
                    if (post.imageLink != null && post.imageLink!.isNotEmpty)
                      _buildImageCarousel(post.imageLink!),
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
                    Row(
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
                        Spacer(),
                        Text(
                          '${post.commentList?.length ?? post.commentNumber} bình luận',
                          style: AppTextStyles.s12Regular(),
                        ),
                        SizedBox(width: 16.sp),
                        Text(
                          '${post.shareNumber} lượt chia sẻ',
                          style: AppTextStyles.s12Regular(),
                        ),
                      ],
                    ),
                    Container(height: 1.sp, color: Colors.grey[200]),
                    Row(
                      children: [
                        ActionButton(
                          iconVector: post.liked
                              ? AppVectors.heartSolid
                              : AppVectors.heart,
                          label: 'Thích',
                          onPressed: () {
                            context.read<PostDetailBloc>().add(
                              ToggleLikePostDetail(post.id),
                            );
                          },
                          iconColor: post.liked
                              ? AppColors.red
                              : AppColors.text_color_200,
                          textColor: post.liked
                              ? AppColors.red
                              : AppColors.text_color_400,
                        ),
                        Container(
                          width: 1.sp,
                          height: 40.sp,
                          color: Colors.grey[200],
                        ),
                        ActionButton(
                          iconVector: AppVectors.comment,
                          label: 'Bình luận',
                          onPressed: () {},
                        ),
                        Container(
                          width: 1.sp,
                          height: 40.sp,
                          color: Colors.grey[200],
                        ),
                        ActionButton(
                          iconVector: AppVectors.share,
                          label: 'Chia sẻ',
                          onPressed: () {
                            DeepLinkService().copyLinkToClipboard(
                              context,
                              host: 'post',
                              params: {'id': post.id},
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16.sp),
                    Container(height: 1.sp, color: Colors.grey[200]),
                    SizedBox(height: 16.sp),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isReplying) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.sp,
                              vertical: 8.sp,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary_main.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.sp),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.reply,
                                  size: 16.sp,
                                  color: AppColors.primary_main,
                                ),
                                SizedBox(width: 8.sp),
                                Text(
                                  'Đang trả lời $replyingToUsername',
                                  style: AppTextStyles.s12Regular(
                                    color: AppColors.primary_main,
                                  ),
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: _cancelReply,
                                  child: Icon(
                                    Icons.close,
                                    size: 16.sp,
                                    color: AppColors.primary_main,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.sp),
                        ],
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 16.sp,
                              backgroundColor: Colors.green[200],
                              child: Text(
                                'M',
                                style: AppTextStyles.s12Bold(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.sp),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20.sp),
                                ),
                                child: TextField(
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                    hintText: isReplying
                                        ? 'Trả lời $replyingToUsername...'
                                        : 'Viết bình luận...',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.sp,
                                      vertical: 8.sp,
                                    ),
                                    hintStyle: AppTextStyles.s14Regular(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  style: AppTextStyles.s14Regular(),
                                  onSubmitted: (value) => _addComment(value),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.sp),
                            IconButton(
                              onPressed: () =>
                                  _addComment(_commentController.text),
                              icon: SvgPicture.asset(
                                AppVectors.send,
                                width: 28.sp,
                                height: 28.sp,
                                color: AppColors.primary_main,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.sp),
                    if (post.commentList != null &&
                        post.commentList!.isNotEmpty)
                      _buildCommentTree(post.commentList!)
                    else
                      Center(
                        child: Text(
                          'Chưa có bình luận nào',
                          style: AppTextStyles.s14Regular(color: Colors.grey),
                        ),
                      ),
                    SizedBox(height: 16.sp),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _handleReply(String username, String commentId) {
    setState(() {
      isReplying = true;
      replyingToUsername = username;
      replyingToCommentId = commentId;
    });
  }

  void _cancelReply() {
    setState(() {
      isReplying = false;
      replyingToUsername = '';
      replyingToCommentId = null;
      _commentController.clear();
    });
  }

  void _toggleExpanded(String commentId) {
    setState(() {
      if (_expandedComments.contains(commentId)) {
        _expandedComments.remove(commentId);
      } else {
        _expandedComments.add(commentId);
      }
    });
  }

  Widget _buildCommentTree(List<CommentEntity> comments) {
    // Separate top-level comments and replies
    final topLevelComments = comments
        .where(
          (c) =>
              c.parentId == null || c.parentId!.isEmpty || c.parentId == c.id,
        )
        .toList();

    // Group ALL replies by parent (for recursive lookup)
    final Map<String, List<CommentEntity>> repliesMap = {};
    for (final comment in comments) {
      if (comment.parentId != null &&
          comment.parentId!.isNotEmpty &&
          comment.parentId != comment.id) {
        repliesMap.putIfAbsent(comment.parentId!, () => []);
        repliesMap[comment.parentId!]!.add(comment);
      }
    }

    return Column(
      children: topLevelComments.map((comment) {
        return _buildCommentWithReplies(comment, repliesMap, 0);
      }).toList(),
    );
  }

  /// Count all nested replies recursively
  int _countAllReplies(
    String commentId,
    Map<String, List<CommentEntity>> repliesMap,
  ) {
    final directReplies = repliesMap[commentId] ?? [];
    int count = directReplies.length;
    for (final reply in directReplies) {
      count += _countAllReplies(reply.id, repliesMap);
    }
    return count;
  }

  Widget _buildCommentWithReplies(
    CommentEntity comment,
    Map<String, List<CommentEntity>> repliesMap,
    int depth,
  ) {
    final isExpanded = _expandedComments.contains(comment.id);
    final directReplies = repliesMap[comment.id] ?? [];
    final hasReplies = directReplies.isNotEmpty;
    final totalReplies = _countAllReplies(comment.id, repliesMap);

    // Calculate indent based on depth (max 3 levels of indentation)
    final double indent = (depth > 0) ? 32.sp : 0;
    final bool isTopLevel = depth == 0;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComment(comment, isTopLevel: isTopLevel),
          if (hasReplies) ...[
            GestureDetector(
              onTap: () => _toggleExpanded(comment.id),
              child: Padding(
                padding: EdgeInsets.only(left: 40.sp, top: 4.sp, bottom: 4.sp),
                child: Row(
                  children: [
                    Container(
                      width: 24.sp,
                      height: 1.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      isExpanded
                          ? 'Ẩn $totalReplies phản hồi'
                          : 'Xem $totalReplies phản hồi',
                      style: AppTextStyles.s12SemiBold(
                        color: AppColors.primary_main,
                      ),
                    ),
                    SizedBox(width: 4.sp),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16.sp,
                      color: AppColors.primary_main,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded && depth < 1)
              Column(
                children: directReplies.map((reply) {
                  // Recursively build nested replies
                  return _buildCommentWithReplies(reply, repliesMap, depth + 1);
                }).toList(),
              ),
          ],
        ],
      ),
    );
  }

  void _addComment(String content) {
    if (content.trim().isNotEmpty) {
      context.read<PostDetailBloc>().add(
        CreateCommentEvent(
          widget.postId,
          content,
          parentId: replyingToCommentId,
        ),
      );
      _commentController.clear();
      // Reset reply state after submission
      if (isReplying) {
        setState(() {
          isReplying = false;
          replyingToUsername = '';
          replyingToCommentId = null;
        });
      }
      FocusScope.of(context).unfocus();
    }
  }

  Widget _buildImageCarousel(List<String> imageLinks) {
    final ValueNotifier<int> currentPage = ValueNotifier<int>(0);
    final PageController pageController = PageController();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 300.sp,
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

  Widget _buildComment(CommentEntity comment, {bool isTopLevel = true}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.0.sp),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserProfileScreen(userId: comment.userId),
                  ),
                );
              },
              child: CircleAvatar(
                radius: isTopLevel ? 16.sp : 14.sp,
                backgroundColor: Colors.green[200],
                backgroundImage: comment.avatar.isNotEmpty
                    ? NetworkImage(comment.avatar)
                    : null,
                child: comment.avatar.isEmpty
                    ? Text(
                        comment.fullName.isNotEmpty ? comment.fullName[0] : '?',
                        style: isTopLevel
                            ? AppTextStyles.s12Bold(color: Colors.white)
                            : AppTextStyles.s10Bold(color: Colors.white),
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(width: 8.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(isTopLevel ? 12.sp : 10.sp),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfileScreen(
                                      userId: comment.userId,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                comment.isMe ? 'Bạn' : comment.fullName,
                                style:
                                    (isTopLevel
                                            ? AppTextStyles.s14Bold()
                                            : AppTextStyles.s12Bold())
                                        .copyWith(
                                          color: comment.isMe
                                              ? Colors.green
                                              : Colors.black,
                                        ),
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_horiz,
                              size: 16.sp,
                              color: Colors.grey[600],
                            ),
                            padding: EdgeInsets.zero,
                            onSelected: (value) {
                              if (value == 'report') {
                                ReportModal.show(
                                  context,
                                  comment.id,
                                  'COMMENT',
                                );
                              }
                            },
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                value: 'report',
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      AppVectors.report,
                                      width: 20.sp,
                                      height: 20.sp,
                                      color: AppColors.text_color_400,
                                    ),
                                    SizedBox(width: 8.sp),
                                    Text('Báo cáo'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 2.sp),
                      Text(
                        comment.content,
                        style: isTopLevel
                            ? AppTextStyles.s14Regular()
                            : AppTextStyles.s12Regular(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.sp),
                Padding(
                  padding: EdgeInsets.only(left: 8.0.sp),
                  child: Row(
                    children: [
                      Text(
                        _formatTimeAgo(comment.createdAt),
                        style: AppTextStyles.s12Regular(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      InkWell(
                        onTap: () {
                          context.read<PostDetailBloc>().add(
                            ToggleLikeComment(widget.postId, comment.id),
                          );
                        },
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              comment.isLike
                                  ? AppVectors.heartSolid
                                  : AppVectors.heart,
                              color: AppColors.red,
                              width: 16.sp,
                              height: 16.sp,
                            ),
                            SizedBox(width: 4.sp),
                            Text(
                              '${comment.likeNumber}',
                              style: AppTextStyles.s12Regular(
                                color: comment.isLike
                                    ? AppColors.red
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      if (isTopLevel)
                        GestureDetector(
                          onTap: () {
                            _handleReply(comment.fullName, comment.id);
                          },
                          child: Text(
                            'Trả lời',
                            style: AppTextStyles.s12SemiBold(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 0) {
      return '${duration.inDays} ngày trước';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} giờ trước';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
