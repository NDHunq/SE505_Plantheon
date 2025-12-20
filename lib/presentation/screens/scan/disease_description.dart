import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/services/token_storage_service.dart';
import 'package:se501_plantheon/data/models/diseases.model.dart';
import 'package:se501_plantheon/data/datasources/complaint_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/complaint_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/complaint/submit_scan_complaint.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_event.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_state.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_event.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_state.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_provider.dart';
import 'package:se501_plantheon/presentation/bloc/complaint/complaint_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/complaint/complaint_event.dart';
import 'package:se501_plantheon/presentation/bloc/complaint/complaint_state.dart';
import 'package:se501_plantheon/presentation/screens/scan/scan_solution.dart';
import 'package:se501_plantheon/presentation/screens/scan/image_comparison_screen.dart';
import 'package:se501_plantheon/core/services/supabase_service.dart';
import 'package:toastification/toastification.dart';

class DiseaseDescriptionScreen extends StatefulWidget {
  final String diseaseLabel;
  final bool isPreview;
  final List<String>? otherdiseaseLabels;
  final File? myImage;
  final String? myImageLink;
  final double? confidenceScore;

  const DiseaseDescriptionScreen({
    super.key,
    required this.diseaseLabel,
    this.isPreview = false,
    this.otherdiseaseLabels,
    this.myImage,
    this.myImageLink,
    this.confidenceScore,
  });

  @override
  State<DiseaseDescriptionScreen> createState() =>
      _DiseaseDescriptionScreenState();
}

class _DiseaseDescriptionScreenState extends State<DiseaseDescriptionScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentImageIndex = 0;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isLoadingTts = false;

  @override
  void initState() {
    super.initState();
    print(
      '🚀 Screen: initState called with diseaseLabel: ${widget.diseaseLabel}',
    );
    _initTts();
    context.read<DiseaseBloc>().add(
      GetDiseaseEvent(diseaseId: widget.diseaseLabel),
    );
    print('📤 Screen: GetDiseaseEvent sent to BLoC');
    print("my image link in initState: ${widget.myImageLink}");
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary_100,
      appBar: BasicAppbar(
        title: "Chẩn đoán",
        // actions: [
        //   GestureDetector(
        //     onTap: () {
        //       showDialog(
        //         context: context,
        //         builder: (context) => BasicDialog(
        //           title: 'Xóa chẩn đoán',
        //           content: 'Bạn có chắc chắn muốn xóa chẩn đoán này?',
        //           confirmText: 'Xóa',
        //           cancelText: 'Huỷ',
        //           onConfirm: () {},
        //           onCancel: () {},
        //         ),
        //       );
        //     },
        //     child: SvgPicture.asset(
        //       AppVectors.trash,
        //       width: 24.sp,
        //       height: 24.sp,
        //       color: AppColors.red,
        //     ),
        //   ),
        //   SizedBox(width: 16.sp),
        // ],
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
            final disease =
                state.disease; // Capture disease for use in nested builders
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
                                onTap: _isLoadingTts
                                    ? null
                                    : () {
                                        _handleListenTap(disease.description);
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (_isLoadingTts)
                                        SizedBox(
                                          width: 26.sp,
                                          height: 26.sp,
                                          child: LoadingIndicator(
                                            size: 26.sp,
                                            padding: EdgeInsets.zero,
                                          ),
                                        )
                                      else
                                        Icon(
                                          _isSpeaking
                                              ? Icons.stop_circle_outlined
                                              : Icons.volume_up,
                                          color: AppColors.primary_400,
                                          size: 24.sp,
                                        ),
                                      Text(
                                        _isLoadingTts
                                            ? ' Đang tải...'
                                            : _isSpeaking
                                            ? ' Dừng đọc'
                                            : ' Nghe mô tả',
                                        style: AppTextStyles.s16SemiBold(
                                          color: AppColors.primary_400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // HTML Content Section
                              _buildMarkdownContentSection(state.disease),

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
                    : ScanHistoryProvider(
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                left: 16.sp,
                                right: 16.sp,
                                top: 16.sp,
                                bottom: 16.sp,
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
                              child: BlocConsumer<ScanHistoryBloc, ScanHistoryState>(
                                listener: (context, state) {
                                  if (state is CreateScanHistorySuccess) {
                                    print(
                                      '✅ UI: Scan history created successfully with id: ${state.scanHistory.id}',
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ScanHistoryProvider(
                                              child: ScanSolution(
                                                scanHistoryId:
                                                    state.scanHistory.id,
                                              ),
                                            ),
                                      ),
                                    );
                                  } else if (state is ScanHistoryError) {
                                    print(
                                      '❌ UI: Error creating scan history: ${state.message}',
                                    );
                                    toastification.show(
                                      context: context,
                                      type: ToastificationType.error,
                                      style: ToastificationStyle.flat,
                                      title: Text('Lỗi: ${state.message}'),
                                      autoCloseDuration: const Duration(
                                        seconds: 3,
                                      ),
                                      alignment: Alignment.bottomCenter,
                                      showProgressBar: true,
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  final isLoading = state is ScanHistoryLoading;
                                  return ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            print(
                                              '🔘 UI: Confirm button pressed, creating scan history for disease: ${disease.id}',
                                            );

                                            context.read<ScanHistoryBloc>().add(
                                              CreateScanHistoryEvent(
                                                diseaseId: disease.id,
                                                scanImage: widget.myImage,
                                              ),
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary_main,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.sp,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.sp,
                                        ),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: isLoading
                                        ? SizedBox(
                                            height: 20.sp,
                                            width: 20.sp,
                                            child: LoadingIndicator(),
                                          )
                                        : Text(
                                            'Xác nhận & Xem điều trị',
                                            style: AppTextStyles.s16SemiBold(
                                              color: Colors.white,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.sp),
                              decoration: BoxDecoration(color: Colors.white),
                              child: FutureBuilder<SharedPreferences>(
                                future: SharedPreferences.getInstance(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return ElevatedButton(
                                      onPressed: null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.white,
                                        foregroundColor: AppColors.primary_main,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16.sp,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.sp,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: AppColors.primary_main,
                                          width: 1,
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        'Báo cáo',
                                        style: AppTextStyles.s16SemiBold(
                                          color: AppColors.primary_main,
                                        ),
                                      ),
                                    );
                                  }

                                  return BlocProvider(
                                    create: (context) => ComplaintBloc(
                                      submitScanComplaint: SubmitScanComplaint(
                                        repository: ComplaintRepositoryImpl(
                                          remoteDataSource:
                                              ComplaintRemoteDataSourceImpl(
                                                client: http.Client(),
                                                baseUrl:
                                                    ApiConstants.diseaseApiUrl,
                                                tokenStorage:
                                                    TokenStorageService(
                                                      prefs: snapshot.data!,
                                                    ),
                                              ),
                                        ),
                                      ),
                                      complaintRepository:
                                          ComplaintRepositoryImpl(
                                            remoteDataSource:
                                                ComplaintRemoteDataSourceImpl(
                                                  client: http.Client(),
                                                  baseUrl: ApiConstants
                                                      .diseaseApiUrl,
                                                  tokenStorage:
                                                      TokenStorageService(
                                                        prefs: snapshot.data!,
                                                      ),
                                                ),
                                          ),
                                    ),
                                    child: BlocConsumer<ComplaintBloc, ComplaintState>(
                                      listener: (context, state) {
                                        if (state is ComplaintSuccess) {
                                          toastification.show(
                                            context: context,
                                            type: ToastificationType.success,
                                            style: ToastificationStyle.flat,
                                            title: Text(
                                              'Đã gửi báo cáo thành công',
                                            ),
                                            description: Text(
                                              'Cảm ơn bạn đã góp ý! Chúng tôi sẽ xem xét và cải thiện.',
                                            ),
                                            autoCloseDuration: const Duration(
                                              seconds: 3,
                                            ),
                                            alignment: Alignment.bottomCenter,
                                            showProgressBar: true,
                                          );
                                        } else if (state is ComplaintError) {
                                          toastification.show(
                                            context: context,
                                            type: ToastificationType.error,
                                            style: ToastificationStyle.flat,
                                            title: Text('Lỗi gửi báo cáo'),
                                            description: Text(state.message),
                                            autoCloseDuration: const Duration(
                                              seconds: 3,
                                            ),
                                            alignment: Alignment.bottomCenter,
                                            showProgressBar: true,
                                          );
                                        }
                                      },
                                      builder: (context, state) {
                                        final isLoading =
                                            state is ComplaintLoading;
                                        return ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : () {
                                                  _showComplaintDialog(
                                                    context,
                                                    disease,
                                                  );
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.white,
                                            foregroundColor:
                                                AppColors.primary_main,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 16.sp,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.sp),
                                            ),
                                            side: BorderSide(
                                              color: AppColors.primary_main,
                                              width: 1,
                                            ),
                                            elevation: 0,
                                          ),
                                          child: isLoading
                                              ? SizedBox(
                                                  height: 20.sp,
                                                  width: 20.sp,
                                                  child: LoadingIndicator(),
                                                )
                                              : Text(
                                                  'Báo cáo',
                                                  style:
                                                      AppTextStyles.s16SemiBold(
                                                        color: AppColors
                                                            .primary_main,
                                                      ),
                                                ),
                                        );
                                      },
                                    ),
                                  );
                                },
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
                            myImage: widget.myImage != null
                                ? widget.myImage!
                                : File(''),
                            diseaseImageUrls: disease.imageLink,
                            initialIndex: index,
                            myImageLink: widget.myImageLink ?? '',
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

  Widget _buildMarkdownContentSection(DiseaseModel disease) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstraints.mainPadding.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarkdownBody(
            data: disease.description,
            styleSheet: MarkdownStyleSheet(
              h2: AppTextStyles.s20Bold(
                color: AppColors.primary_600,
              ).copyWith(height: 1.5),
              h3: AppTextStyles.s16SemiBold(
                color: AppColors.primary_400,
              ).copyWith(height: 1.5),
              h4: AppTextStyles.s14SemiBold(
                color: AppColors.primary_600,
              ).copyWith(height: 1.5),
              p: AppTextStyles.s14Regular(
                color: Colors.black87,
              ).copyWith(height: 1.6),
              listBullet: AppTextStyles.s14Regular(
                color: Colors.black87,
              ).copyWith(height: 1.5),
              strong: AppTextStyles.s14SemiBold(color: AppColors.primary_700),
              em: AppTextStyles.s14Regular(
                color: Colors.black87,
              ).copyWith(fontStyle: FontStyle.italic),
              blockSpacing: 16.sp,
              listIndent: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('vi-VN');
    await _flutterTts.setSpeechRate(0.5); // Tốc độ đọc (0.0 - 1.0)
    await _flutterTts.setVolume(1.0); // Âm lượng (0.0 - 1.0)
    await _flutterTts.setPitch(1.0); // Cao độ giọng nói (0.5 - 2.0)
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() {
      if (!mounted) return;
      setState(() {
        _isSpeaking = true;
        _isLoadingTts = false;
      });
    });

    _flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });

    _flutterTts.setCancelHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((message) {
      print('TTS error: $message');
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _handleListenTap(String markdownlContent) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      return;
    }

    final textToSpeak = _stripMarkdownTags(markdownlContent);
    print('🗣️ TTS: Text length: ${textToSpeak.length} characters');
    if (textToSpeak.isEmpty) return;

    setState(() => _isLoadingTts = true);

    try {
      // Split long text into chunks to avoid Android TTS limitations
      final chunks = _splitTextIntoChunks(textToSpeak, maxLength: 4000);
      print('🗣️ TTS: Split into ${chunks.length} chunks');

      for (int i = 0; i < chunks.length; i++) {
        if (!_isSpeaking && i > 0) break; // Stop if user cancelled
        print('🗣️ TTS: Speaking chunk ${i + 1}/${chunks.length}');
        await _flutterTts.speak(chunks[i]);
      }

      // Fallback: Reset loading state after a short delay if startHandler wasn't called
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && _isLoadingTts) {
        setState(() {
          _isLoadingTts = false;
          _isSpeaking = true;
        });
      }
    } catch (e) {
      print('TTS speak error: $e');
      if (mounted) {
        setState(() => _isLoadingTts = false);
      }
    }
  }

  List<String> _splitTextIntoChunks(String text, {int maxLength = 4000}) {
    if (text.length <= maxLength) return [text];

    final chunks = <String>[];
    var currentChunk = '';

    // Split by sentences (. ! ?)
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));

    for (final sentence in sentences) {
      // If single sentence is too long, split by words
      if (sentence.length > maxLength) {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk.trim());
          currentChunk = '';
        }

        final words = sentence.split(' ');
        for (final word in words) {
          if ((currentChunk + ' ' + word).length > maxLength) {
            if (currentChunk.isNotEmpty) {
              chunks.add(currentChunk.trim());
              currentChunk = word;
            } else {
              chunks.add(word); // Single word too long, add anyway
            }
          } else {
            currentChunk += (currentChunk.isEmpty ? '' : ' ') + word;
          }
        }
      } else {
        // Add sentence to current chunk if it fits
        if ((currentChunk + ' ' + sentence).length > maxLength) {
          if (currentChunk.isNotEmpty) {
            chunks.add(currentChunk.trim());
          }
          currentChunk = sentence;
        } else {
          currentChunk += (currentChunk.isEmpty ? '' : ' ') + sentence;
        }
      }
    }

    // Add remaining chunk
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.trim());
    }

    return chunks;
  }

  String _stripMarkdownTags(String markdownString) {
    // Remove markdown formatting for TTS
    String text = markdownString;

    // Remove headers (##, ###, etc.)
    text = text.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');

    // Remove code blocks first (```code```) to avoid conflicts
    text = text.replaceAll(RegExp(r'```[^`]*```', multiLine: true), '');

    // Remove inline code (`code`) - keep the content
    text = text.replaceAllMapped(
      RegExp(r'`([^`]+)`'),
      (match) => match.group(1) ?? '',
    );

    // Remove bold (**text** or __text__) - process bold before italic
    text = text.replaceAllMapped(
      RegExp(r'\*\*(.+?)\*\*'),
      (match) => match.group(1) ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'__(.+?)__'),
      (match) => match.group(1) ?? '',
    );

    // Remove italic (*text* or _text_)
    text = text.replaceAllMapped(
      RegExp(r'\*(.+?)\*'),
      (match) => match.group(1) ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'\b_(.+?)_\b'),
      (match) => match.group(1) ?? '',
    );

    // Remove strikethrough (~~text~~)
    text = text.replaceAllMapped(
      RegExp(r'~~(.+?)~~'),
      (match) => match.group(1) ?? '',
    );

    // Remove images ![alt](url) - keep alt text
    text = text.replaceAllMapped(
      RegExp(r'!\[([^\]]*)\]\([^)]+\)'),
      (match) => match.group(1) ?? '',
    );

    // Remove links [text](url) - keep link text
    text = text.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]+\)'),
      (match) => match.group(1) ?? '',
    );

    // Remove horizontal rules (---, ***, ___)
    text = text.replaceAll(RegExp(r'^[-*_]{3,}\s*$', multiLine: true), '');

    // Remove blockquotes (>)
    text = text.replaceAll(RegExp(r'^>\s+', multiLine: true), '');

    // Remove unordered list markers (-, *, +)
    text = text.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '');

    // Remove ordered list markers (1., 2., etc.)
    text = text.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');

    // Remove HTML tags if any remain
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    // Clean up multiple spaces and newlines
    text = text.replaceAll(RegExp(r'\n+'), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    return text.trim();
  }

  void _showComplaintDialog(BuildContext context, DiseaseModel disease) {
    String selectedCategory = 'WRONG_RESULT';
    final TextEditingController contentController = TextEditingController();

    // Save bloc reference before showing dialog
    final complaintBloc = context.read<ComplaintBloc>();

    final Map<String, String> categoryLabels = {
      'WRONG_RESULT': 'Kết quả hoàn toàn sai',
      'MISIDENTIFIED': 'Nhận diện sai bệnh',
      'INCORRECT_INFO': 'Thông tin không chính xác',
      'POOR_QUALITY': 'Chất lượng kém',
      'OTHER_ISSUE': 'Vấn đề khác',
    };

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.sp),
          ),
          title: Text(
            'Báo cáo kết quả scan',
            style: AppTextStyles.s16Bold(color: AppColors.primary_700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loại vấn đề:',
                  style: AppTextStyles.s14SemiBold(
                    color: AppColors.primary_600,
                  ),
                ),
                SizedBox(height: 8.sp),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary_300),
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      items: categoryLabels.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(
                            entry.value,
                            style: AppTextStyles.s14Regular(),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Chi tiết (tùy chọn):',
                  style: AppTextStyles.s14SemiBold(
                    color: AppColors.primary_600,
                  ),
                ),
                SizedBox(height: 8.sp),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText: 'Mô tả chi tiết vấn đề bạn gặp phải...',
                    hintStyle: AppTextStyles.s14Regular(
                      color: AppColors.primary_300,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                      borderSide: BorderSide(color: AppColors.primary_300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.sp),
                      borderSide: BorderSide(color: AppColors.primary_main),
                    ),
                  ),
                  style: AppTextStyles.s14Regular(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Hủy',
                style: AppTextStyles.s14SemiBold(color: AppColors.primary_400),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                await _submitComplaint(
                  complaintBloc,
                  disease,
                  selectedCategory,
                  contentController.text.trim().isEmpty
                      ? null
                      : contentController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary_main,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.sp),
                ),
              ),
              child: Text(
                'Gửi báo cáo',
                style: AppTextStyles.s14SemiBold(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComplaint(
    ComplaintBloc complaintBloc,
    DiseaseModel disease,
    String category,
    String? content,
  ) async {
    try {
      // Upload image to Supabase if available
      String? imageUrl = widget.myImageLink;

      if (widget.myImage != null && imageUrl == null) {
        print('📸 Uploading complaint image to Supabase...');
        final bytes = await widget.myImage!.readAsBytes();
        final fileName =
            'complaint_${DateTime.now().millisecondsSinceEpoch}.jpg';

        imageUrl = await SupabaseService.uploadFileFromBytes(
          bucketName: 'uploads',
          fileBytes: bytes,
          fileName: fileName,
        );
        print('✅ Image uploaded successfully: $imageUrl');
      }

      if (imageUrl == null) {
        throw Exception('Không có ảnh để báo cáo');
      }

      // Get confidence score, default to 0.0 if not available
      final confidenceScore = widget.confidenceScore ?? 0.0;

      // Submit complaint via BLoC
      complaintBloc.add(
        SubmitScanComplaintEvent(
          predictedDiseaseId: disease.id,
          confidenceScore: confidenceScore,
          category: category,
          imageUrl: imageUrl,
          content: content,
        ),
      );
    } catch (e) {
      print('❌ Error submitting complaint: $e');
      // Error will be shown via BLoC listener
    }
  }
}
