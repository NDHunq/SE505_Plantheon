import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  // Trạng thái like cho từng post (theo index)
  Map<int, bool> likedPosts = {};
  Map<int, int> likeCounts = {};

  // Controllers cho dialog post
  final TextEditingController _postController = TextEditingController();
  List<Map<String, dynamic>> posts = [];

  // Dropdown cho thể loại bài viết
  String _selectedCategory = 'Đời sống';
  final List<String> _categories = [
    'Đời sống',
    'Cây trồng',
    'Chăm sóc',
    'Kinh nghiệm',
    'Thảo luận',
    'Hỏi đáp',
    'Khác',
  ];

  // Image picker
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo số lượt thích ban đầu
    likeCounts = {0: 28, 1: 15, 2: 42};

    // Khởi tạo danh sách posts mặc định
    posts = [
      {
        'username': 'Mot Nguyen',
        'timeAgo': '15 phút',
        'content':
            'Chào mọi người đây là cây mới của mình.\nHãy theo dõi mình nhé!',
        'category': 'Đời sống',
        'imageUrl': 'https://via.placeholder.com/400x300',
        'likes': 28,
        'comments': 10,
        'shares': 1,
      },
      {
        'username': 'Plant Lover',
        'timeAgo': '1 giờ',
        'content': 'Cây xanh đẹp quá! Có ai biết cách chăm sóc không?',
        'category': 'Hỏi đáp',
        'imageUrl': 'https://via.placeholder.com/400x300',
        'likes': 15,
        'comments': 5,
        'shares': 2,
      },
      {
        'username': 'Green Garden',
        'timeAgo': '3 giờ',
        'content': 'Chia sẻ kinh nghiệm trồng cây trong nhà',
        'category': 'Kinh nghiệm',
        'imageUrl': 'https://via.placeholder.com/400x300',
        'likes': 42,
        'comments': 18,
        'shares': 7,
      },
    ];
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _toggleLike(int postIndex, int originalLikes) {
    setState(() {
      bool isLiked = likedPosts[postIndex] ?? false;
      likedPosts[postIndex] = !isLiked;

      if (!isLiked) {
        // Thích bài viết
        likeCounts[postIndex] = (likeCounts[postIndex] ?? originalLikes) + 1;
      } else {
        // Bỏ thích
        likeCounts[postIndex] = (likeCounts[postIndex] ?? originalLikes) - 1;
      }
    });
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedImages = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      if (pickedImages.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedImages);
        });
      }
    } catch (e) {
      // Handle error
      print('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showPostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: 500.sp,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.sp),
                topRight: Radius.circular(20.sp),
              ),
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40.sp,
                        height: 4.sp,
                        margin: EdgeInsets.only(bottom: 16.sp),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.sp),
                        ),
                      ),
                    ),
                    // Header với nút Hủy và Đăng
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _postController.clear();
                            _selectedImages.clear();
                          },
                          child: Text(
                            'Hủy',
                            style: AppTextStyles.s16Regular(
                              color: AppColors.text_color_200,
                            ),
                          ),
                        ),
                        Text('Bài viết mới', style: AppTextStyles.s16Bold()),
                        TextButton(
                          onPressed: () {
                            _createPost();
                          },
                          child: Text(
                            'Đăng',
                            style: AppTextStyles.s16Bold(
                              color: AppColors.primary_main,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.sp),

                    // Thông tin user
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20.sp,
                          backgroundColor: Colors.green[200],
                          child: Text(
                            'M',
                            style: AppTextStyles.s16Bold(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 12.sp),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mot Nguyen', style: AppTextStyles.s16Bold()),
                            Row(
                              children: [
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCategory,
                                    style: AppTextStyles.s12Regular(
                                      color: Colors.grey[600],
                                    ),
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 16.sp,
                                      color: Colors.grey[600],
                                    ),
                                    items: _categories.map((String category) {
                                      return DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(category),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedCategory = newValue!;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 8.sp),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.sp),

                    // Text input
                    Container(
                      height: 120.sp,
                      child: TextField(
                        controller: _postController,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: 'Bạn đang nghĩ gì ?',
                          border: InputBorder.none,
                          hintStyle: AppTextStyles.s16Regular(
                            color: AppColors.text_color_100,
                          ),
                        ),
                        style: AppTextStyles.s16Regular(),
                      ),
                    ),

                    SizedBox(height: 16.sp),

                    // Image selection area
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: 120.sp,
                        maxHeight: _selectedImages.isEmpty ? 120.sp : 300.sp,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.sp),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: _selectedImages.isEmpty
                          ? InkWell(
                              onTap: _pickImages,
                              child: Container(
                                height: 120.sp,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 60.sp,
                                      height: 60.sp,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(
                                          12.sp,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.add_photo_alternate,
                                        size: 30.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 8.sp),
                                    Text(
                                      'Thêm ảnh',
                                      style: AppTextStyles.s14Regular(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with image count and add more button
                                Padding(
                                  padding: EdgeInsets.all(12.sp),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${_selectedImages.length} ảnh đã chọn',
                                        style: AppTextStyles.s14Regular(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: _pickImages,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.sp,
                                            vertical: 6.sp,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary_main
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              16.sp,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.add,
                                                size: 16.sp,
                                                color: AppColors.primary_main,
                                              ),
                                              SizedBox(width: 4.sp),
                                              Text(
                                                'Thêm ảnh',
                                                style: AppTextStyles.s12Regular(
                                                  color: AppColors.primary_main,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Images grid
                                Container(
                                  height: 200.sp,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.sp,
                                    ),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 8.sp,
                                            mainAxisSpacing: 8.sp,
                                            childAspectRatio: 1,
                                          ),
                                      itemCount: _selectedImages.length,
                                      itemBuilder: (context, index) {
                                        return Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.sp),
                                                image: DecorationImage(
                                                  image: FileImage(
                                                    File(
                                                      _selectedImages[index]
                                                          .path,
                                                    ),
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 4.sp,
                                              right: 4.sp,
                                              child: InkWell(
                                                onTap: () =>
                                                    _removeImage(index),
                                                child: Container(
                                                  padding: EdgeInsets.all(2.sp),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 16.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.sp),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _createPost() {
    if (_postController.text.trim().isNotEmpty) {
      setState(() {
        posts.insert(0, {
          'username': 'Mot Nguyen',
          'timeAgo': 'Vừa xong',
          'content': _postController.text.trim(),
          'category': _selectedCategory,
          'imageUrl': 'https://via.placeholder.com/400x300',
          'likes': 0,
          'comments': 0,
          'shares': 0,
        });

        Map<int, bool> newLikedPosts = {};
        Map<int, int> newLikeCounts = {};

        likedPosts.forEach((key, value) {
          newLikedPosts[key + 1] = value;
        });

        likeCounts.forEach((key, value) {
          newLikeCounts[key + 1] = value;
        });

        likedPosts = newLikedPosts;
        likeCounts = newLikeCounts;
        likeCounts[0] = 0;
      });

      _postController.clear();
      _selectedCategory = 'Đời sống';
      _selectedImages.clear();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
              onPressed: () {},
            ),
            SizedBox(width: 12.sp),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showPostDialog();
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

        body: Padding(
          padding: EdgeInsets.only(left: 16.sp, right: 16.sp, bottom: 60.sp),
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.sp),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          // User info header
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

          Text(content, style: AppTextStyles.s14Regular()),

          // Post image
          SizedBox(
            width: double.infinity,
            height: 300.sp,
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
          // Action buttons
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
    );
  }

  Widget _ActionButton({
    required String iconVector,
    required String label,
    required VoidCallback onPressed,
    Color? iconColor,
    Color? textColor,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Column(
          spacing: 2,
          children: [
            SvgPicture.asset(
              iconVector,
              color: iconColor ?? AppColors.text_color_200,
              width: 24.sp,
              height: 24.sp,
            ),
            Text(
              label,
              style: AppTextStyles.s12Regular(
                color: textColor ?? AppColors.text_color_400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
