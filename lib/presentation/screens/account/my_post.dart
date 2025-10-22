import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/community/post_detail.dart';

class MyPost extends StatefulWidget {
  const MyPost({super.key});

  @override
  State<MyPost> createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  // Trạng thái like cho từng post (theo index)
  Map<int, bool> likedPosts = {};
  Map<int, int> likeCounts = {};

  // Danh sách bài viết của tôi (giả lập)
  List<Map<String, dynamic>> myPosts = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo số lượt thích ban đầu
    likeCounts = {0: 12, 1: 7};
    // Danh sách bài viết của tôi (giả lập)
    myPosts = [
      {
        'username': 'Mot Nguyen',
        'timeAgo': '1 phút',
        'content': 'Đây là bài viết đầu tiên của tôi về cây trồng.',
        'category': 'Cây trồng',
        'imageUrl': 'https://via.placeholder.com/400x300',
        'likes': 12,
        'comments': 2,
        'shares': 0,
      },
      {
        'username': 'Mot Nguyen',
        'timeAgo': '2 ngày',
        'content': 'Chia sẻ kinh nghiệm chăm sóc cây trong nhà.',
        'category': 'Kinh nghiệm',
        'imageUrl': 'https://via.placeholder.com/400x300',
        'likes': 7,
        'comments': 1,
        'shares': 1,
      },
    ];
  }

  void _toggleLike(int postIndex, int originalLikes) {
    setState(() {
      bool isLiked = likedPosts[postIndex] ?? false;
      likedPosts[postIndex] = !isLiked;
      if (!isLiked) {
        likeCounts[postIndex] = (likeCounts[postIndex] ?? originalLikes) + 1;
      } else {
        likeCounts[postIndex] = (likeCounts[postIndex] ?? originalLikes) - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(title: 'Bài viết của tôi'),
      backgroundColor: AppColors.white,
      body: myPosts.isEmpty
          ? Center(
              child: Text(
                'Bạn chưa có bài viết nào.',
                style: AppTextStyles.s16Regular(),
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
              child: ListView.builder(
                itemCount: myPosts.length,
                itemBuilder: (context, index) {
                  final post = myPosts[index];
                  return _buildPost(
                    postIndex: index,
                    username: post['username'],
                    timeAgo: post['timeAgo'],
                    content: post['content'],
                    category: post['category'],
                    imageUrl: post['imageUrl'],
                    likes: post['likes'],
                    comments: post['comments'],
                    shares: post['shares'],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildPost({
    required int postIndex,
    required String username,
    required String timeAgo,
    required String content,
    required String category,
    required String imageUrl,
    required int likes,
    required int comments,
    required int shares,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PostDetail(
              username: username,
              category: category,
              timeAgo: timeAgo,
              content: content,
              imageUrl: imageUrl,
              likes: likes,
              comments: comments,
              shares: shares,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.sp),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              ],
            ),
            SizedBox(height: 8.sp),
            Text(content, style: AppTextStyles.s14Regular()),
            SizedBox(height: 8.sp),
            // Post image
            SizedBox(
              width: double.infinity,
              height: 200.sp,
              child: Image.network(
                imageUrl,
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
            Row(
              children: [
                SvgPicture.asset(
                  likedPosts[postIndex] == true
                      ? AppVectors.heartSolid
                      : AppVectors.heart,
                  color: AppColors.red,
                  width: 16.sp,
                  height: 16.sp,
                ),
                SizedBox(width: 4.sp),
                Text(
                  '${likeCounts[postIndex] ?? likes} lượt thích',
                  style: AppTextStyles.s12Regular(),
                ),
                const Spacer(),
                Text('$comments bình luận', style: AppTextStyles.s12Regular()),
                SizedBox(width: 16.sp),
                Text('$shares lượt chia sẻ', style: AppTextStyles.s12Regular()),
              ],
            ),
            Container(height: 1.sp, color: Colors.grey[200]),
            Row(
              children: [
                _ActionButton(
                  iconVector: likedPosts[postIndex] == true
                      ? AppVectors.heartSolid
                      : AppVectors.heart,
                  label: 'Thích',
                  onPressed: () => _toggleLike(postIndex, likes),
                  iconColor: likedPosts[postIndex] == true
                      ? AppColors.red
                      : AppColors.text_color_200,
                  textColor: likedPosts[postIndex] == true
                      ? AppColors.red
                      : AppColors.text_color_400,
                ),
                Container(width: 1.sp, height: 40.sp, color: Colors.grey[200]),
                _ActionButton(
                  iconVector: AppVectors.comment,
                  label: 'Bình luận',
                  onPressed: () {},
                ),
                Container(width: 1.sp, height: 40.sp, color: Colors.grey[200]),
                _ActionButton(
                  iconVector: AppVectors.share,
                  label: 'Chia sẻ',
                  onPressed: () {},
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

class _ActionButton extends StatelessWidget {
  final String iconVector;
  final String label;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? textColor;

  const _ActionButton({
    required this.iconVector,
    required this.label,
    required this.onPressed,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconVector,
              color: iconColor ?? AppColors.text_color_200,
              width: 18.sp,
              height: 18.sp,
            ),
            SizedBox(width: 6.sp),
            Text(
              label,
              style: AppTextStyles.s14Regular(
                color: textColor ?? AppColors.text_color_400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
