import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/disease_card.dart';

class Blogs extends StatefulWidget {
  const Blogs({super.key});

  @override
  State<Blogs> createState() => _BlogsState();
}

class _BlogsState extends State<Blogs> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tất cả';
  String _selectedSort = 'Mới nhất';
  String _tempSelectedSort = 'Mới nhất';

  final List<String> _filterOptions = [
    'Tất cả',
    'Bệnh cây',
    'Kỹ thuật',
    'Chăm sóc',
    'Tin nóng',
  ];

  // Sample data for blogs
  final List<Map<String, String>> _blogPosts = [
    {
      'title': 'Bệnh rệp sáp trên cây trồng',
      'description': 'Rệp sáp là một loại côn trùng gây hại cho cây trồng.',
      'image': 'assets/images/plants.jpg',
      'category': 'Bệnh cây',
    },
    {
      'title': 'Kỹ thuật trồng cà chua',
      'description': 'Hướng dẫn chi tiết về cách trồng cà chua hiệu quả.',
      'image': 'assets/images/plants.jpg',
      'category': 'Kỹ thuật',
    },
    {
      'title': 'Chăm sóc cây trồng mùa mưa',
      'description': 'Những lưu ý quan trọng khi chăm sóc cây vào mùa mưa.',
      'image': 'assets/images/plants.jpg',
      'category': 'Chăm sóc',
    },
    {
      'title': 'Phân bón hữu cơ tự nhiên',
      'description': 'Cách làm phân bón hữu cơ tại nhà cho cây trồng.',
      'image': 'assets/images/plants.jpg',
      'category': 'Kỹ thuật',
    },
    {
      'title': 'Bệnh đốm lá trên cây ăn quả',
      'description': 'Nhận biết và phòng trừ bệnh đốm lá hiệu quả.',
      'image': 'assets/images/plants.jpg',
      'category': 'Bệnh cây',
    },
    {
      'title': 'Tin nóng: Hướng dẫn chăm sóc rau mùa đông',
      'description': 'Các loại rau phù hợp trồng vào mùa đông.',
      'image': 'assets/images/plants.jpg',
      'category': 'Tin nóng',
    },
    {
      'title': 'Phương pháp tưới nước hiệu quả',
      'description': 'Kỹ thuật tưới nước đúng cách cho cây trồng.',
      'image': 'assets/images/plants.jpg',
      'category': 'Chăm sóc',
    },
    {
      'title': 'Bệnh thối rễ và cách khắc phục',
      'description': 'Nguyên nhân và giải pháp cho bệnh thối rễ cây.',
      'image': 'assets/images/plants.jpg',
      'category': 'Bệnh cây',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredPosts {
    if (_selectedFilter == 'Tất cả') {
      return _blogPosts;
    }
    return _blogPosts
        .where((post) => post['category'] == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: BasicAppbar(
        title: 'Tin tức',
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              AppVectors.filter,
              color: AppColors.primary_700,
              height: 24.sp,
              width: 24.sp,
            ),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8.sp,
                  offset: Offset(0, 2.sp),
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              decoration: BoxDecoration(
                color: AppColors.text_color_50.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24.sp),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm tin tức...',
                  border: InputBorder.none,
                  hintStyle: AppTextStyles.s14Regular(
                    color: AppColors.text_color_100,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.text_color_200,
                    size: 20.sp,
                  ),
                ),
                style: AppTextStyles.s14Regular(),
              ),
            ),
          ),

          // Filter Chips
          Container(
            height: 50.sp,
            padding: EdgeInsets.symmetric(vertical: 8.sp),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: EdgeInsets.only(right: 8.sp),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(
                      filter,
                      style: AppTextStyles.s12Medium(
                        color: isSelected
                            ? AppColors.primary_main
                            : AppColors.text_color_400,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: AppColors.white,
                    selectedColor: AppColors.primary_50,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary_main
                          : AppColors.text_color_50,
                      width: 1.sp,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.sp),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.sp),
                    ),
                  ),
                );
              },
            ),
          ),

          // Blog Grid
          Expanded(
            child: _filteredPosts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64.sp,
                          color: AppColors.text_color_100,
                        ),
                        SizedBox(height: 16.sp),
                        Text(
                          'Không có bài viết nào',
                          style: AppTextStyles.s16Medium(
                            color: AppColors.text_color_200,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16.sp),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.sp,
                      mainAxisSpacing: 12.sp,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = _filteredPosts[index];
                      return DiseaseWarningCard(
                        title: post['title']!,
                        description: post['description']!,
                        imagePath: post['image']!,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    _tempSelectedSort = _selectedSort;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.sp),
                  topRight: Radius.circular(20.sp),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8.sp),
                      width: 40.sp,
                      height: 4.sp,
                      decoration: BoxDecoration(
                        color: AppColors.text_color_100,
                        borderRadius: BorderRadius.circular(2.sp),
                      ),
                    ),

                    // Header with title and clear button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bộ lọc',
                          style: AppTextStyles.s20Bold(
                            color: AppColors.primary_main,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _tempSelectedSort = 'Mới nhất';
                            });
                          },
                          child: Text(
                            'Làm sạch',
                            style: AppTextStyles.s14Medium(
                              color: AppColors.primary_main,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.sp),

                    // Sort by section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sắp xếp theo',
                        style: AppTextStyles.s16Bold(),
                      ),
                    ),

                    SizedBox(height: 12.sp),

                    // Sort buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildSortButton(
                            'Mới nhất',
                            _tempSelectedSort == 'Mới nhất',
                            () {
                              setModalState(() {
                                _tempSelectedSort = 'Mới nhất';
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        Expanded(
                          child: _buildSortButton(
                            'Cũ nhất',
                            _tempSelectedSort == 'Cũ nhất',
                            () {
                              setModalState(() {
                                _tempSelectedSort = 'Cũ nhất';
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        Expanded(
                          child: _buildSortButton(
                            'Phổ biến nhất',
                            _tempSelectedSort == 'Phổ biến nhất',
                            () {
                              setModalState(() {
                                _tempSelectedSort = 'Phổ biến nhất';
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.sp),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.sp),
                              side: BorderSide(
                                color: AppColors.primary_main,
                                width: 1.sp,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                            ),
                            child: Text(
                              'Hủy bỏ',
                              style: AppTextStyles.s16Medium(
                                color: AppColors.primary_main,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedSort = _tempSelectedSort;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.sp),
                              backgroundColor: AppColors.primary_main,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                            ),
                            child: Text(
                              'Áp dụng',
                              style: AppTextStyles.s16Bold(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.sp),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.sp),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.text_color_50 : AppColors.white,
          borderRadius: BorderRadius.circular(8.sp),
          border: Border.all(color: AppColors.text_color_50, width: 1.sp),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.s12Medium(color: AppColors.text_color_400),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
