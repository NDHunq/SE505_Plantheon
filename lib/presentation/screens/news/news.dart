import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/news/detail_news.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/disease_card.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
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

  // Sample data with markdown content
  final List<Map<String, dynamic>> _blogPosts = [
    {
      'title': 'Bệnh rệp sáp trên cây trồng',
      'description': 'Rệp sáp là một loại côn trùng gây hại cho cây trồng.',
      'image': 'assets/images/plants.jpg',
      'category': 'Bệnh cây',
      'date': '2 giờ trước',
      'markdownContent': '''
# Bệnh rệp sáp trên cây trồng

Rệp sáp là một loại côn trùng gây hại phổ biến trên nhiều loại cây trồng.

## Nguyên nhân

- Rệp sáp sinh sôi nhanh trong điều kiện nóng ẩm
- Chúng hút nhựa cây làm cây yếu đi
- Phát triển mạnh ở môi trường thiếu ánh sáng

## Triệu chứng

- **Lá vàng**: Cây bị mất dinh dưỡng
- **Cành khô**: Rệp hút nhựa làm cành khô dần
- **Xuất hiện màng trắng**: Màng bảo vệ của rệp

## Biện pháp phòng trừ

### 1. Biện pháp cơ học
- Lau sạch rệp bằng khăn ẩm
- Cắt tỉa những cành bị nặng
- Tăng cường ánh sáng và thoáng khí

### 2. Biện pháp hóa học
Sử dụng các loại thuốc:
- Thuốc có hoạt chất **Imidacloprid**
- Xịt vào sáng sớm hoặc chiều mát
- Phun đều các mặt lá

### 3. Biện pháp sinh học
- Nuôi thiên địch như bọ rùa
- Dùng dầu neem phun định kỳ
- Trồng cây xua đuổi như húng quế

## Lưu ý quan trọng

> Khi phát hiện rệp sáp, nên xử lý sớm để tránh lây lan.

### Cách kiểm tra
1. Quan sát thân và lá cây
2. Kiểm tra mặt dưới lá
3. Tìm các đốm trắng nhỏ

Kết luận: Rệp sáp có thể kiểm soát được nếu phát hiện sớm và xử lý đúng cách.
''',
    },
    {
      'title': 'Kỹ thuật trồng cà chua',
      'description': 'Hướng dẫn chi tiết về cách trồng cà chua hiệu quả.',
      'image': 'assets/images/plants.jpg',
      'category': 'Kỹ thuật',
      'date': '5 giờ trước',
      'markdownContent': '''
# Kỹ thuật trồng cà chua

Cà chua là loại cây dễ trồng và cho năng suất cao.

## Chuẩn bị đất

- Đất tơi xốp, giàu dinh dưỡng
- Độ pH từ **6.0 đến 6.8**
- Thoát nước tốt

## Cách trồng

### Bước 1: Gieo hạt
- Ngâm hạt 6-8 tiếng
- Gieo sâu khoảng 1cm
- Tưới nước nhẹ hàng ngày

### Bước 2: Chăm sóc
- Tưới nước đều đặn
- Bón phân định kỳ 2 tuần/lần
- Làm cỏ thường xuyên

## Thu hoạch
Thu hoạch khi quả chín đỏ, vỏ căng bóng.
''',
    },
    {
      'title': 'Chăm sóc cây trồng mùa mưa',
      'description': 'Những lưu ý quan trọng khi chăm sóc cây vào mùa mưa.',
      'image': 'assets/images/plants.jpg',
      'category': 'Chăm sóc',
      'date': '1 ngày trước',
      'markdownContent': '''
# Chăm sóc cây trồng mùa mưa

Mùa mưa cần có cách chăm sóc đặc biệt cho cây trồng.

## Các biện pháp bảo vệ

### 1. Tránh úng nước
- Đảm bảo thoát nước tốt
- Nâng cao luống trồng
- Đục lỗ thoát nước ở chậu

### 2. Phòng trừ bệnh
- Phun thuốc trừ nấm định kỳ
- Tăng cường ánh sáng
- Cắt tỉa lá già

## Lưu ý đặc biệt

> Không tưới quá nhiều nước khi trời mưa.

Tránh để đất quá ẩm ướt.
''',
    },
    {
      'title': 'Phân bón hữu cơ tự nhiên',
      'description': 'Cách làm phân bón hữu cơ tại nhà cho cây trồng.',
      'image': 'assets/images/plants.jpg',
      'category': 'Kỹ thuật',
      'date': '2 ngày trước',
      'markdownContent': '''
# Phân bón hữu cơ tự nhiên

Phân bón hữu cơ là giải pháp tốt cho cây trồng.

## Nguyên liệu cần thiết

- Vỏ chuối
- Vỏ trứng
- Nước vo gạo
- Rác hữu cơ

## Cách làm

1. Cắt nhỏ vỏ chuối
2. Nghiền vỏ trứng
3. Trộn đều với rác hữu cơ
4. Ủ trong 2-4 tuần

## Cách sử dụng

- Pha loãng với nước
- Tưới vào gốc cây
- Bón định kỳ 2 tuần/lần
''',
    },
    {
      'title': 'Bệnh đốm lá trên cây ăn quả',
      'description': 'Nhận biết và phòng trừ bệnh đốm lá hiệu quả.',
      'image': 'assets/images/plants.jpg',
      'category': 'Bệnh cây',
      'date': '3 ngày trước',
      'markdownContent': '''
# Bệnh đốm lá trên cây ăn quả

Bệnh đốm lá ảnh hưởng nghiêm trọng đến năng suất cây trồng.

## Triệu chứng

- Xuất hiện đốm nâu trên lá
- Lá khô và rụng sớm
- Giảm quang hợp

## Nguyên nhân

- Môi trường ẩm ướt
- Nấm bệnh lây lan
- Không khí lưu thông kém

## Biện pháp khắc phục

### Phòng ngừa
- Trồng thưa để thoáng khí
- Tưới gốc, không tưới lá

### Điều trị
- Cắt bỏ lá bệnh
- Phun thuốc có **Copper**
- Bón phân cân đối
''',
    },
    {
      'title': 'Tin nóng: Hướng dẫn chăm sóc rau mùa đông',
      'description': 'Các loại rau phù hợp trồng vào mùa đông.',
      'image': 'assets/images/plants.jpg',
      'category': 'Tin nóng',
      'date': '1 tuần trước',
      'markdownContent': '''
# Hướng dẫn chăm sóc rau mùa đông

Mùa đông có nhiều loại rau đặc biệt phù hợp.

## Các loại rau mùa đông

### 1. Xà lách
- Ưa mát mẻ
- Trồng dưới 20°C
- Thu hoạch sau 30 ngày

### 2. Cải bó xôi
- Chịu lạnh tốt
- Nhiều dinh dưỡng
- Dễ chăm sóc

### 3. Củ cải
- Trồng vụ đông
- Thu hoạch 40-50 ngày
- Củ to và ngọt

## Kỹ thuật chăm sóc

- Che chắn khi gió lạnh
- Tưới nước ít hơn
- Bón phân hữu cơ
''',
    },
    {
      'title': 'Phương pháp tưới nước hiệu quả',
      'description': 'Kỹ thuật tưới nước đúng cách cho cây trồng.',
      'image': 'assets/images/plants.jpg',
      'category': 'Chăm sóc',
      'date': '1 tuần trước',
      'markdownContent': '''
# Phương pháp tưới nước hiệu quả

Nước là yếu tố quan trọng nhất cho cây trồng.

## Các phương pháp tưới

### 1. Tưới nhỏ giọt
- Tiết kiệm nước
- Cây hấp thụ tốt
- Không làm ướt lá

### 2. Tưới phun sương
- Dùng cho cây nhỏ
- Mát mẻ vào nắng nóng
- Tránh lúc trời nắng

### 3. Tưới gốc
- Dùng cho cây lớn
- Tập trung vào rễ
- Tiết kiệm nước

## Thời điểm tưới

- **Sáng sớm**: Tốt nhất
- **Chiều mát**: Sau 17h
- Tránh tưới giữa trưa

## Lượng nước

- Cây nhỏ: 1-2 lít/tuần
- Cây trung: 3-5 lít/tuần  
- Cây lớn: 10-20 lít/tuần
''',
    },
    {
      'title': 'Bệnh thối rễ và cách khắc phục',
      'description': 'Nguyên nhân và giải pháp cho bệnh thối rễ cây.',
      'image': 'assets/images/plants.jpg',
      'category': 'Bệnh cây',
      'date': '2 tuần trước',
      'markdownContent': '''
# Bệnh thối rễ và cách khắc phục

Thối rễ là bệnh nguy hiểm, khó chữa.

## Nguyên nhân

- Tưới quá nhiều nước
- Đất không thoát nước
- Rễ bị tổn thương
- Nấm bệnh xâm nhập

## Triệu chứng

1. Lá vàng và rụng
2. Cây héo dần
3. Rễ màu đen
4. Mùi hôi thối

## Cách khắc phục

### Khi mới phát hiện
- Ngừng tưới nước
- Thay đất mới
- Cắt rễ thối

### Nếu nặng
- Cắt bỏ phần rễ thối
- Xử lý bằng thuốc
- Trồng lại đất mới

## Phòng ngừa

> Luôn đảm bảo thoát nước tốt.

- Không tưới quá nhiều
- Đất tơi xốp
- Kiểm tra rễ định kỳ
''',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPosts {
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
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailNews(
                                title: post['title'],
                                description: post['description'],
                                imagePath: post['image'],
                                category: post['category'],
                                date: post['date'] ?? '2 giờ trước',
                                markdownContent: post['markdownContent'] ?? '',
                              ),
                            ),
                          );
                        },
                        child: DiseaseWarningCard(
                          title: post['title'],
                          description: post['description'],
                          imagePath: post['image'],
                        ),
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
