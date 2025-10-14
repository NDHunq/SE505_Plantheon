import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/common/widgets/topnavigation/navigation.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/data/models/diseases.model.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_event.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_state.dart';

class DiseaseDescriptionScreen extends StatefulWidget {
  final String diseaseId;

  const DiseaseDescriptionScreen({super.key, required this.diseaseId});

  @override
  State<DiseaseDescriptionScreen> createState() =>
      _DiseaseDescriptionScreenState();
}

class _DiseaseDescriptionScreenState extends State<DiseaseDescriptionScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    print('🚀 Screen: initState called with diseaseId: ${widget.diseaseId}');
    context.read<DiseaseBloc>().add(
      GetDiseaseEvent(diseaseId: widget.diseaseId),
    );
    print('📤 Screen: GetDiseaseEvent sent to BLoC');
  }

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
        actions: [],
      ),
      body: BlocBuilder<DiseaseBloc, DiseaseState>(
        builder: (context, state) {
          print('🔄 UI: BlocBuilder rebuild with state: ${state.runtimeType}');
          if (state is DiseaseLoading) {
            print('⏳ UI: Showing loading state');
            return const Center(child: CircularProgressIndicator());
          } else if (state is DiseaseError) {
            print('❌ UI: Showing error state: ${state.message}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${state.message}',
                    style: AppTextStyles.s16Regular(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DiseaseBloc>().add(
                        GetDiseaseEvent(diseaseId: widget.diseaseId),
                      );
                    },
                    child: Text('Thử lại', style: AppTextStyles.s16Medium()),
                  ),
                ],
              ),
            );
          } else if (state is DiseaseSuccess) {
            print(
              '✅ UI: Showing success state with disease: ${state.disease.name}',
            );
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disease Info Section
                  _buildDiseaseInfoSection(state.disease),

                  // Image Carousel Section
                  _buildImageCarouselSection(state.disease),

                  // HTML Content Section
                  _buildHtmlContentSection(state.disease),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDiseaseInfoSection(DiseaseModel disease) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstraints.mainPadding.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            disease.name,
            style: AppTextStyles.s20Bold(color: AppColors.primary_600),
          ),
          SizedBox(height: 8.sp),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.sp),
              border: Border.all(color: AppColors.primary_300),
            ),
            child: Text(
              disease.type,
              style: AppTextStyles.s14Medium(color: AppColors.primary_700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarouselSection(DiseaseModel disease) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.sp),
        SizedBox(
          height: 200.sp,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: disease.imageLink.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: AppConstraints.mainPadding.sp,
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
                  child: Image.network(
                    disease.imageLink[index],
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
        SizedBox(height: 12.sp),
        // Page indicators
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              disease.imageLink.length,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4.sp),
                width: _currentImageIndex == index ? 24.sp : 8.sp,
                height: 8.sp,
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? AppColors.primary_600
                      : AppColors.primary_300,
                  borderRadius: BorderRadius.circular(4.sp),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 24.sp),
      ],
    );
  }

  Widget _buildHtmlContentSection(DiseaseModel disease) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstraints.mainPadding.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Html(
            data: disease.description,
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
                margin: Margins.only(top: 0, bottom: 12),
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
