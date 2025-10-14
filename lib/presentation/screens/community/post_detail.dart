import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/acction_button.dart';

class PostDetail extends StatefulWidget {
  final String username;
  final String category;
  final String timeAgo;
  final String content;
  final String imageUrl;
  final int likes;
  final int comments;
  final int shares;

  const PostDetail({
    super.key,
    required this.username,
    required this.category,
    required this.timeAgo,
    required this.content,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> commentsList = [];
  late int currentLikes;
  late int currentComments;
  bool isLiked = false;

  // Reply functionality
  bool isReplying = false;
  String replyingToUsername = '';

  @override
  void initState() {
    super.initState();
    currentLikes = widget.likes;
    currentComments = widget.comments;

    // Initialize with some sample comments
    commentsList = [
      {
        'username': 'Alice Green',
        'timeAgo': '1 giờ',
        'content': 'Cây của bạn đẹp quá! Có thể chia sẻ cách chăm sóc không?',
        'likes': 5,
        'isLiked': false,
      },
      {
        'username': 'Garden Master',
        'timeAgo': '30 phút',
        'content': 'Tôi cũng trồng loại này, rất dễ chăm sóc đấy!',
        'likes': 3,
        'isLiked': false,
      },
    ];
  }

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
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.sp,
              backgroundColor: Colors.green[200],
              child: Text(
                widget.username[0],
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
                      Text(widget.username, style: AppTextStyles.s16Bold()),
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
                    '${widget.category} • ${widget.timeAgo}',
                    style: AppTextStyles.s12Regular(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              AppVectors.postReport,
              width: 20.sp,
              height: 20.sp,
              color: Colors.grey[600],
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(AppVectors.arrowBack, width: 28, height: 28),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 16.sp, right: 16.sp),
        child: SingleChildScrollView(
          child: Column(
            spacing: 8.sp,
            children: [
              Text(widget.content, style: AppTextStyles.s14Regular()),
              SizedBox(
                width: double.infinity,
                height: 300.sp,
                child: Image.network(
                  widget.imageUrl,
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
              Row(
                children: [
                  SvgPicture.asset(
                    AppVectors.heart,
                    color: AppColors.red,
                    width: 16.sp,
                    height: 16.sp,
                  ),
                  SizedBox(width: 4.sp),
                  Text(
                    '${currentLikes} lượt thích',
                    style: AppTextStyles.s12Regular(),
                  ),
                  const Spacer(),
                  Text(
                    '${currentComments} bình luận',
                    style: AppTextStyles.s12Regular(),
                  ),
                  SizedBox(width: 16.sp),
                  Text(
                    '${widget.shares} lượt chia sẻ',
                    style: AppTextStyles.s12Regular(),
                  ),
                ],
              ),
              Container(height: 1.sp, color: Colors.grey[200]),
              Row(
                children: [
                  ActionButton(
                    iconVector: isLiked
                        ? AppVectors.heartSolid
                        : AppVectors.heart,
                    label: 'Thích',
                    onPressed: _toggleLike,
                    iconColor: isLiked
                        ? AppColors.red
                        : AppColors.text_color_200,
                    textColor: isLiked
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
                          style: AppTextStyles.s12Bold(color: Colors.white),
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
                            onSubmitted: (value) => _addComment(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      IconButton(
                        onPressed: _addComment,
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
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: commentsList.length,
                itemBuilder: (context, index) {
                  final comment = commentsList[index];
                  return _buildComment(comment, index);
                },
              ),
              SizedBox(height: 16.sp),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      currentLikes += isLiked ? 1 : -1;
    });
  }

  void _handleReply(String username) {
    setState(() {
      isReplying = true;
      replyingToUsername = username;
      _commentController.text = '@$username ';
    });

    // Focus vào text field và đặt cursor ở cuối
    Future.delayed(Duration(milliseconds: 100), () {
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

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        commentsList.insert(0, {
          'username': 'Mot Nguyen',
          'timeAgo': 'Vừa xong',
          'content': _commentController.text.trim(),
          'likes': 0,
          'isLiked': false,
        });
        currentComments++;

        // Reset reply state
        isReplying = false;
        replyingToUsername = '';
      });
      _commentController.clear();
    }
  }

  void _toggleCommentLike(int index) {
    setState(() {
      commentsList[index]['isLiked'] = !commentsList[index]['isLiked'];
      commentsList[index]['likes'] += commentsList[index]['isLiked'] ? 1 : -1;
    });
  }

  Widget _buildComment(Map<String, dynamic> comment, int index) {
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
              child: Text(
                comment['username'][0],
                style: AppTextStyles.s12Bold(color: Colors.white),
              ),
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
                      Text(comment['username'], style: AppTextStyles.s14Bold()),
                      SizedBox(height: 2.sp),
                      Text(
                        comment['content'],
                        style: AppTextStyles.s14Regular(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.sp),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      Text(
                        comment['timeAgo'],
                        style: AppTextStyles.s12Regular(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      InkWell(
                        onTap: () => _toggleCommentLike(index),
                        child: Row(
                          children: [
                            Icon(
                              comment['isLiked']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16.sp,
                              color: comment['isLiked']
                                  ? AppColors.red
                                  : Colors.grey[600],
                            ),
                            SizedBox(width: 4.sp),
                            Text(
                              '${comment['likes']}',
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
                          _handleReply(comment['username']);
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
}
