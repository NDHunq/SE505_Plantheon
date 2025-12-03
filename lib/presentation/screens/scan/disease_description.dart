import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/dialog/basic_dialog.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/data/models/diseases.model.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_event.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_state.dart';
import 'package:se501_plantheon/presentation/screens/scan/scan_solution.dart';
import 'package:se501_plantheon/presentation/screens/scan/image_comparison_screen.dart';
import 'package:se501_plantheon/data/datasources/disease_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/disease_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/disease/get_disease.dart';
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';

class DiseaseDescriptionScreen extends StatefulWidget {
  final String diseaseLabel;
  final bool isPreview;
  final List<String>? otherdiseaseLabels;
  final File? myImage;

  const DiseaseDescriptionScreen({
    super.key,
    required this.diseaseLabel,
    this.isPreview = false,
    this.otherdiseaseLabels,
    this.myImage,
  });

  @override
  State<DiseaseDescriptionScreen> createState() =>
      _DiseaseDescriptionScreenState();
}

class _DiseaseDescriptionScreenState extends State<DiseaseDescriptionScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    print(
      '🚀 Screen: initState called with diseaseLabel: ${widget.diseaseLabel}',
    );
    context.read<DiseaseBloc>().add(
      GetDiseaseEvent(diseaseId: widget.diseaseLabel),
    );
    print('📤 Screen: GetDiseaseEvent sent to BLoC');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary_100,
      appBar: BasicAppbar(
        title: "Chẩn đoán",
        actions: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => BasicDialog(
                  title: 'Xóa chẩn đoán',
                  content: 'Bạn có chắc chắn muốn xóa chẩn đoán này?',
                  confirmText: 'Xóa',
                  cancelText: 'Huỷ',
                  onConfirm: () {},
                  onCancel: () {},
                ),
              );
            },
            child: SvgPicture.asset(
              AppVectors.trash,
              width: 24.sp,
              height: 24.sp,
              color: AppColors.red,
            ),
          ),
          SizedBox(width: 16.sp),
        ],
      ),
      body: BlocBuilder<DiseaseBloc, DiseaseState>(
        builder: (context, state) {
          print('🔄 UI: BlocBuilder rebuild with state: ${state.runtimeType}');
          if (state is DiseaseLoading) {
            print('⏳ UI: Showing loading state');
            return const Center(child: LoadingIndicator());
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
                        GetDiseaseEvent(diseaseId: widget.diseaseLabel),
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
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Disease Info Section
                        _buildDiseaseInfoSection(state.disease),

                        // Image Carousel Section
                        _buildImageCarouselSection(state.disease),
                        Container(
                          padding: EdgeInsets.all(
                            AppConstraints.mainPadding.sp,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24.sp),
                              topRight: Radius.circular(24.sp),
                            ),
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  // TODO: Handle listen description tap
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.volume_up,
                                        color: AppColors.primary_400,
                                        size: 24.sp,
                                      ),
                                      Text(
                                        ' Nghe mô tả',
                                        style: AppTextStyles.s16SemiBold(
                                          color: AppColors.primary_400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // HTML Content Section
                              _buildHtmlContentSection(state.disease),

                              // Padding để nội dung không bị che bởi button
                              SizedBox(height: 80.sp),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.isPreview
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(
                              left: 16.sp,
                              right: 16.sp,
                              top: 16.sp,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                print(
                                  '➡️ Navigating to ScanSolution with diseaseLabel: ${widget.diseaseLabel}',
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BlocProvider<DiseaseBloc>(
                                          create: (context) => DiseaseBloc(
                                            getDisease: GetDisease(
                                              repository: DiseaseRepositoryImpl(
                                                remoteDataSource:
                                                    DiseaseRemoteDataSourceImpl(
                                                      client: http.Client(),
                                                      baseUrl: ApiConstants
                                                          .diseaseApiUrl,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          child: ScanSolution(
                                            diseaseLabel: widget.diseaseLabel,
                                          ),
                                        ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary_main,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.sp),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.sp),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Xác nhận & Xem điều trị',
                                style: AppTextStyles.s16SemiBold(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.sp),
                            decoration: BoxDecoration(color: Colors.white),
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Handle button press
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                foregroundColor: AppColors.primary_main,
                                padding: EdgeInsets.symmetric(vertical: 16.sp),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.sp),
                                ),
                                side: BorderSide(
                                  color: AppColors.primary_main,
                                  width: 1,
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Xem các chẩn đoán tương tự',
                                style: AppTextStyles.s16SemiBold(
                                  color: AppColors.primary_main,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
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
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            disease.name,
            style: AppTextStyles.s20Bold(color: AppColors.primary_700),
          ),
          SizedBox(height: 8.sp),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.sp),
              border: Border.all(color: AppColors.primary_700),
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
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: disease.imageLink.length,
          itemBuilder: (context, index, realIndex) {
            return Stack(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.sp),
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
                        return Image.network(
                          'https://wallpapers.com/images/hd/banana-tree-pictures-fta1lapzcih69mdr.jpg',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12.sp,
                  right: 20.sp,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageComparisonScreen(
                            myImage: widget.myImage,
                            diseaseImageUrls: disease.imageLink,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(8.sp),
                      child: Icon(
                        Icons.ads_click_rounded,
                        color: AppColors.white,
                        size: 26.sp,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          options: CarouselOptions(
            height: 200.sp,
            viewportFraction: 0.8,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            autoPlay: true,
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
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
