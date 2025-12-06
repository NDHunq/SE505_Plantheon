import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/data/datasources/post_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/post_repository_impl.dart';
import 'package:se501_plantheon/domain/entities/comment_entity.dart';
import 'package:se501_plantheon/presentation/bloc/post_detail/post_detail_bloc.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/acction_button.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/disease_block_widget.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/report_button.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/presentation/bloc/auth/auth_bloc.dart';
import 'package:se501_plantheon/data/repository/auth_repository_impl.dart';

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
          icon: SvgPicture.asset(AppVectors.arrowBack, width: 28, height: 28),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: BlocBuilder<PostDetailBloc, PostDetailState>(
          builder: (context, state) {
            if (state is PostDetailLoaded) {
              return Row(
                children: [
                  CircleAvatar(
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
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              state.post.fullName,
                              style: AppTextStyles.s16Bold(),
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
        actions: [ReportButton(context: context)],
      ),
      body: BlocBuilder<PostDetailBloc, PostDetailState>(
        builder: (context, state) {
          if (state is PostDetailLoading) {
            return const Center(child: CircularProgressIndicator());
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
                      SizedBox(
                        width: double.infinity,
                        height: 300.sp,
                        child: Image.network(
                          post.imageLink!.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.sp),
                                color: Colors.grey[300],
                              ),
                              child: Icon(
                                Icons.eco,
                                size: 100.sp,
                                color: Colors.green,
                              ),
                            );
                          },
                        ),
                      ),
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
                          onPressed: () {},
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
                              icon: Icon(
                                Icons.send,
                                color: AppColors.primary_main,
                                size: 20.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.sp),
                    if (post.commentList != null &&
                        post.commentList!.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: post.commentList!.length,
                        itemBuilder: (context, index) {
                          final comment = post.commentList![index];
                          return _buildComment(comment, index);
                        },
                      )
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

  void _handleReply(String username) {
    setState(() {
      isReplying = true;
      replyingToUsername = username;
      _commentController.text = '@$username ';
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _commentController.selection = TextSelection.fromPosition(
        TextPosition(offset: _commentController.text.length),
      );
    });
  }

  void _cancelReply() {
    setState(() {
      isReplying = false;
      replyingToUsername = '';
      _commentController.clear();
    });
  }

  void _addComment(String content) {
    if (content.trim().isNotEmpty) {
      context.read<PostDetailBloc>().add(
        CreateCommentEvent(widget.postId, content),
      );
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Widget _buildComment(CommentEntity comment, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: CircleAvatar(
              radius: 16.sp,
              backgroundColor: Colors.green[200],
              backgroundImage: comment.avatar.isNotEmpty
                  ? NetworkImage(comment.avatar)
                  : null,
              child: comment.avatar.isEmpty
                  ? Text(
                      comment.fullName.isNotEmpty ? comment.fullName[0] : '?',
                      style: AppTextStyles.s12Bold(color: Colors.white),
                    )
                  : null,
            ),
          ),
          SizedBox(width: 8.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.isMe ? 'Bạn' : comment.fullName,
                        style: AppTextStyles.s14Bold().copyWith(
                          color: comment.isMe ? Colors.green : Colors.black,
                        ),
                      ),
                      SizedBox(height: 2.sp),
                      Text(comment.content, style: AppTextStyles.s14Regular()),
                    ],
                  ),
                ),
                SizedBox(height: 4.sp),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
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
                        onTap: () {}, // Implement comment like later
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 16.sp,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4.sp),
                            Text(
                              '${comment.likeNumber}',
                              style: AppTextStyles.s12Regular(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      GestureDetector(
                        onTap: () {
                          _handleReply(comment.fullName);
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
