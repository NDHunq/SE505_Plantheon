import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/home/chat_bot.dart';

class Community extends StatelessWidget {
  const Community({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Hinted search text',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.text_color_100),
                  ),
                ),
              ),
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
            onPressed: () {},
          ),
          SizedBox(width: 12.sp),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatBot()),
          );
        },
        backgroundColor: AppColors.orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.sp),
          side: BorderSide(color: AppColors.orange_400, width: 5.sp),
        ),
        child: SvgPicture.asset(
          AppVectors.chatBot, // Đường dẫn SVG của bạn
          width: 30.sp,
          height: 23.sp,
          color: AppColors.text_color_main,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            _buildPost(
              username: 'Mot Nguyen',
              timeAgo: '15 phút',
              content:
                  'Chào mọi người đây là cây mới của mình.\nHãy theo dõi mình nhé!',
              imageUrl: 'https://via.placeholder.com/400x300',
              likes: 28,
              comments: 10,
              shares: 1,
            ),
            _buildPost(
              username: 'Plant Lover',
              timeAgo: '1 giờ',
              content: 'Cây xanh đẹp quá! Có ai biết cách chăm sóc không?',
              imageUrl: 'https://via.placeholder.com/400x300',
              likes: 15,
              comments: 5,
              shares: 2,
            ),
            _buildPost(
              username: 'Green Garden',
              timeAgo: '3 giờ',
              content: 'Chia sẻ kinh nghiệm trồng cây trong nhà',
              imageUrl: 'https://via.placeholder.com/400x300',
              likes: 42,
              comments: 18,
              shares: 7,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPost({
    required String username,
    required String timeAgo,
    required String content,
    required String imageUrl,
    required int likes,
    required int comments,
    required int shares,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          // User info header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green[200],
                child: Text(
                  username[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Đời sống • $timeAgo',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
            ],
          ),

          Text(content, style: const TextStyle(fontSize: 14)),

          // Post image
          SizedBox(
            width: double.infinity,
            height: 300,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[300],
                  ),
                  child: const Icon(Icons.eco, size: 100, color: Colors.green),
                );
              },
            ),
          ),
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 16),
              const SizedBox(width: 4),
              Text('$likes lượt thích', style: AppTextStyles.s10Regular()),
              const Spacer(),
              Text('$comments bình luận', style: AppTextStyles.s10Regular()),
              const SizedBox(width: 16),
              Text('$shares lượt chia sẻ', style: AppTextStyles.s10Regular()),
            ],
          ),
          // Action buttons
          Container(height: 1, color: Colors.grey[200]),
          Row(
            children: [
              _ActionButton(
                icon: Icons.favorite_border_rounded,
                label: 'Thích',
                onPressed: () {},
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              _ActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Bình luận',
                onPressed: () {},
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              _ActionButton(
                icon: Icons.share_rounded,
                label: 'Chia sẻ',
                onPressed: () {},
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              _ActionButton(
                icon: Icons.bookmark_border_rounded,
                label: 'Báo cáo',
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _ActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Column(
        spacing: 2,
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          Text(label, style: AppTextStyles.s10Regular(color: Colors.grey)),
        ],
      ),
    );
  }
}
