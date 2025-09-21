import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:se501_plantheon/common/widgets/topnavigation/navigation.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class DiseaseDescriptionScreen extends StatefulWidget {
  const DiseaseDescriptionScreen({super.key});

  @override
  State<DiseaseDescriptionScreen> createState() =>
      _DiseaseDescriptionScreenState();
}

class _DiseaseDescriptionScreenState extends State<DiseaseDescriptionScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  // Mock data cho bệnh
  final String diseaseName = "Bệnh đốm lá cà chua";
  final String diseaseType = "Bệnh nấm";
  final List<String> diseaseImages = [
    "assets/images/plants.jpg",
    "assets/images/plants.jpg",
    "assets/images/plants.jpg",
    "assets/images/plants.jpg",
  ];

  // Mock HTML content
  final String htmlContent = """
    <div style="font-family: Arial, sans-serif; line-height: 1.6;">
      <h2 style="color: #2E7D32; margin-bottom: 16px;">Mô tả bệnh</h2>
      <p style="margin-bottom: 16px;">
        Bệnh đốm lá cà chua là một trong những bệnh phổ biến nhất ảnh hưởng đến cây cà chua. 
        Bệnh này do nấm <strong>Alternaria solani</strong> gây ra và thường xuất hiện trong 
        điều kiện thời tiết ẩm ướt.
      </p>
      
      <h3 style="color: #388E3C; margin-top: 24px; margin-bottom: 12px;">Triệu chứng</h3>
      <ul style="margin-bottom: 16px;">
        <li>Xuất hiện các đốm tròn màu nâu đen trên lá</li>
        <li>Đốm có thể lan rộng và hợp nhất với nhau</li>
        <li>Lá vàng và rụng sớm</li>
        <li>Giảm năng suất và chất lượng quả</li>
      </ul>
      
      <h3 style="color: #388E3C; margin-top: 24px; margin-bottom: 12px;">Nguyên nhân</h3>
      <p style="margin-bottom: 16px;">
        Bệnh phát triển mạnh trong điều kiện:
      </p>
      <ul style="margin-bottom: 16px;">
        <li>Độ ẩm cao (>80%)</li>
        <li>Nhiệt độ từ 20-30°C</li>
        <li>Mưa nhiều hoặc tưới nước quá mức</li>
        <li>Thiếu ánh sáng mặt trời</li>
      </ul>
      
      <h3 style="color: #388E3C; margin-top: 24px; margin-bottom: 12px;">Cách phòng trừ</h3>
      <ol style="margin-bottom: 16px;">
        <li><strong>Biện pháp canh tác:</strong>
          <ul>
            <li>Trồng với mật độ phù hợp</li>
            <li>Tưới nước vào gốc, tránh làm ướt lá</li>
            <li>Vệ sinh đồng ruộng, loại bỏ lá bệnh</li>
          </ul>
        </li>
        <li><strong>Biện pháp hóa học:</strong>
          <ul>
            <li>Sử dụng thuốc trừ nấm như Mancozeb, Chlorothalonil</li>
            <li>Phun định kỳ 7-10 ngày/lần</li>
            <li>Luân phiên các loại thuốc để tránh kháng thuốc</li>
          </ul>
        </li>
      </ol>
      
      <div style="background-color: #E8F5E8; padding: 16px; border-radius: 8px; margin-top: 24px;">
        <h4 style="color: #2E7D32; margin-bottom: 8px;">💡 Lưu ý quan trọng</h4>
        <p style="margin: 0;">
          Phát hiện sớm và xử lý kịp thời sẽ giúp giảm thiểu thiệt hại. 
          Nên kiểm tra cây thường xuyên, đặc biệt trong mùa mưa.
        </p>
      </div>
    </div>
  """;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomNavigationBar(
        title: "Chẩn đoán",
        showBackButton: true,
        actions: [
          CommonNavigationActions.share(
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chức năng chia sẻ đang được phát triển'),
                ),
              );
            },
          ),
          CommonNavigationActions.menu(
            onPressed: () {
              // TODO: Implement menu functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu đang được phát triển')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disease Info Section
            _buildDiseaseInfoSection(),

            // Image Carousel Section
            _buildImageCarouselSection(),

            // HTML Content Section
            _buildHtmlContentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstraints.mainPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            diseaseName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary_600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary_100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary_300),
            ),
            child: Text(
              diseaseType,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary_700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarouselSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstraints.mainPadding),
          child: Text(
            "Hình ảnh bệnh",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary_600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: diseaseImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppConstraints.mainPadding,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    diseaseImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary_100,
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: AppColors.primary_400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page indicators
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              diseaseImages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentImageIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? AppColors.primary_600
                      : AppColors.primary_300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHtmlContentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstraints.mainPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Html(
            data: htmlContent,
            style: {
              "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
              "h2": Style(
                color: AppColors.primary_600,
                fontSize: FontSize(20),
                fontWeight: FontWeight.bold,
                margin: Margins.only(bottom: 16),
              ),
              "h3": Style(
                color: AppColors.primary_400,
                fontSize: FontSize(16),
                fontWeight: FontWeight.w600,
                margin: Margins.only(top: 24, bottom: 12),
              ),
              "h4": Style(
                color: AppColors.primary_600,
                fontSize: FontSize(14),
                fontWeight: FontWeight.w600,
                margin: Margins.only(bottom: 8),
              ),
              "p": Style(
                fontSize: FontSize(14),
                lineHeight: const LineHeight(1.6),
                margin: Margins.only(bottom: 16),
                color: Colors.black87,
              ),
              "ul": Style(margin: Margins.only(bottom: 16)),
              "ol": Style(margin: Margins.only(bottom: 16)),
              "li": Style(
                fontSize: FontSize(14),
                lineHeight: const LineHeight(1.5),
                margin: Margins.only(bottom: 4),
                color: Colors.black87,
              ),
              "strong": Style(
                fontWeight: FontWeight.bold,
                color: AppColors.primary_700,
              ),
            },
          ),
        ],
      ),
    );
  }
}
