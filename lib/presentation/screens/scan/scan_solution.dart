import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/data/datasources/activities_remote_datasource.dart';
import 'package:se501_plantheon/data/datasources/keyword_activities_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/activities_repository_impl.dart';
import 'package:se501_plantheon/data/repository/keyword_activity_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/activity/create_activity.dart';
import 'package:se501_plantheon/domain/usecases/activity/delete_activity.dart';
import 'package:se501_plantheon/domain/usecases/activity/get_activities_by_day.dart';
import 'package:se501_plantheon/domain/usecases/activity/get_activities_by_month.dart';
import 'package:se501_plantheon/domain/usecases/activity/update_activity.dart';
import 'package:se501_plantheon/domain/usecases/keyword_activity/get_keyword_activities.dart';
import 'package:se501_plantheon/presentation/screens/scan/activities_suggestion_section.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_event.dart';
import 'package:se501_plantheon/presentation/screens/scan/community_suggestion_widget.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_event.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_state.dart';
import 'package:se501_plantheon/domain/entities/disease_entity.dart';
import 'package:se501_plantheon/presentation/screens/scan/disease_description.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_bloc.dart';
import 'package:se501_plantheon/data/datasources/disease_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/disease_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/disease/get_disease.dart';
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ScanSolution extends StatefulWidget {
  final String scanHistoryId;
  const ScanSolution({super.key, required this.scanHistoryId});

  @override
  State<ScanSolution> createState() => _ScanSolutionState();
}

class _ScanSolutionState extends State<ScanSolution> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isLoadingTts = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    print(
      '🚀 ScanSolution: initState called with scanHistoryId: ${widget.scanHistoryId}',
    );
    context.read<ScanHistoryBloc>().add(
      GetScanHistoryByIdEvent(id: widget.scanHistoryId),
    );
    print('📤 ScanSolution: GetScanHistoryByIdEvent sent to BLoC');
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

  Future<void> _handleListenTap(String markdownContent) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      return;
    }

    var textToSpeak = _stripMarkdownTags(markdownContent);
    print('🗣️ TTS: Text length: ${textToSpeak.length} characters');

    // Only read first 300 characters
    if (textToSpeak.length > 300) {
      textToSpeak = textToSpeak.substring(0, 300);
      print('🗣️ TTS: Text truncated to 300 characters');
    }

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
    String text = markdownString;
    text = text.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'```[^`]*```', multiLine: true), '');
    text = text.replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m.group(1) ?? '');
    text = text.replaceAllMapped(
      RegExp(r'\*\*(.+?)\*\*'),
      (m) => m.group(1) ?? '',
    );
    text = text.replaceAllMapped(RegExp(r'__(.+?)__'), (m) => m.group(1) ?? '');
    text = text.replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => m.group(1) ?? '');
    text = text.replaceAllMapped(
      RegExp(r'\b_(.+?)_\b'),
      (m) => m.group(1) ?? '',
    );
    text = text.replaceAllMapped(RegExp(r'~~(.+?)~~'), (m) => m.group(1) ?? '');
    text = text.replaceAllMapped(
      RegExp(r'!\[([^\]]*)\]\([^)]+\)'),
      (m) => m.group(1) ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]+\)'),
      (m) => m.group(1) ?? '',
    );
    text = text.replaceAll(RegExp(r'^[-*_]{3,}\s*$', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^>\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    text = text.replaceAll(RegExp(r'\n+'), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    return text.trim();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: 'Kết quả quét bệnh',
        actions: [
          Icon(Icons.share_rounded, color: AppColors.primary_main),
          SizedBox(width: 16.sp),
        ],
      ),
      body: BlocBuilder<ScanHistoryBloc, ScanHistoryState>(
        builder: (context, state) {
          if (state is ScanHistoryLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is ScanHistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.sp),
                  Text('Lỗi: ${state.message}'),
                  SizedBox(height: 16.sp),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ScanHistoryBloc>().add(
                        GetScanHistoryByIdEvent(id: widget.scanHistoryId),
                      );
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          } else if (state is GetScanHistoryByIdSuccess) {
            final scanHistory = state.scanHistory;
            final disease = scanHistory.disease;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Diagnosis Result
                  _SectionTitle(index: 1, title: 'Kết quả chẩn đoán'),
                  SizedBox(height: 8.sp),
                  _DiagnosisCard(
                    disease: disease,
                    scanImageUrl: scanHistory.scanImage,
                  ),
                  SizedBox(height: 20.sp),
                  Divider(
                    height: 32.sp,
                    thickness: 1.sp,
                    color: Color(0xFFE0E0E0),
                  ),
                  // 2. Recommended Solution
                  _SectionTitle(
                    index: 2,
                    title: 'Giải pháp khuyến nghị',
                    action: IconButton(
                      onPressed: () {
                        print('🔊 TTS: speak button pressed');
                        _handleListenTap(disease.solution).catchError((e) {
                          print('TTS error: $e');
                        });
                      },
                      icon: _isLoadingTts
                          ? LoadingIndicator(size: 26.sp)
                          : Icon(
                              _isSpeaking
                                  ? Icons.stop_circle_outlined
                                  : Icons.volume_up,
                              color: _isSpeaking
                                  ? AppColors.primary_600
                                  : AppColors.primary_400,
                              size: 24.sp,
                            ),
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8.sp),
                    child: MarkdownBody(
                      data: disease.solution,
                      styleSheet: MarkdownStyleSheet(
                        h3: TextStyle(
                          color: Color(0xFF388E3C),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.5.sp,
                        ),
                        p: TextStyle(
                          fontSize: 14.sp,
                          height: 1.6.sp,
                          color: Colors.black87,
                        ),
                        listBullet: TextStyle(
                          fontSize: 14.sp,
                          height: 1.5.sp,
                          color: Colors.black87,
                        ),
                        strong: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                        em: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                        blockSpacing: 12.sp,
                        listIndent: 24.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.sp),
                  CommunitySuggestionWidget(
                    diseaseId: disease.className,
                    diseaseIdForPost: disease.id,
                    scanImageUrl: scanHistory.scanImage,
                    scanHistoryId: scanHistory.id,
                  ),
                  SizedBox(height: 20.sp),
                  _SectionTitle(index: 3, title: 'Hoạt động gợi ý'),
                  SizedBox(height: 12.sp),
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) {
                          final repository = ActivitiesRepositoryImpl(
                            remoteDataSource: ActivitiesRemoteDataSourceImpl(
                              client: http.Client(),
                            ),
                          );
                          return ActivitiesBloc(
                            getActivitiesByMonth: GetActivitiesByMonth(
                              repository,
                            ),
                            getActivitiesByDay: GetActivitiesByDay(repository),
                            createActivity: CreateActivity(repository),
                            updateActivity: UpdateActivity(repository),
                            deleteActivity: DeleteActivity(repository),
                          );
                        },
                      ),
                      BlocProvider(
                        create: (_) {
                          final repository = KeywordActivityRepositoryImpl(
                            remoteDataSource:
                                KeywordActivitiesRemoteDataSourceImpl(
                                  client: http.Client(),
                                ),
                          );
                          return KeywordActivitiesBloc(
                            getKeywordActivities: GetKeywordActivities(
                              repository,
                            ),
                          )..add(FetchKeywordActivities(diseaseId: disease.id));
                        },
                      ),
                    ],
                    child: ActivitiesSuggestionList(diseaseId: disease.id),
                  ),
                  SizedBox(height: 20.sp),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final int index;
  final String title;
  final Widget? action;
  const _SectionTitle({required this.index, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28.sp,
          height: 28.sp,
          decoration: BoxDecoration(
            color: AppColors.primary_600,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  final DiseaseEntity disease;
  final String? scanImageUrl;
  const _DiagnosisCard({required this.disease, this.scanImageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4.sp,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          print(
            '🚀 DiagnosisCard: Tapped on disease card with label: ${disease.id}',
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider<DiseaseBloc>(
                create: (context) => DiseaseBloc(
                  getDisease: GetDisease(
                    repository: DiseaseRepositoryImpl(
                      remoteDataSource: DiseaseRemoteDataSourceImpl(
                        client: http.Client(),
                        baseUrl: ApiConstants.diseaseApiUrl,
                      ),
                    ),
                  ),
                ),
                child: DiseaseDescriptionScreen(
                  diseaseLabel: disease.className,
                  isPreview: true,
                  myImageLink: scanImageUrl,
                ),
              ),
            ),
          );
        },
        child: ListTile(
          contentPadding: EdgeInsets.all(12.sp),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.sp),
            child: scanImageUrl != null
                ? Image.network(
                    scanImageUrl!,
                    width: 56.sp,
                    height: 56.sp,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return disease.imageLink.isNotEmpty
                          ? Image.network(
                              disease.imageLink[0],
                              width: 56.sp,
                              height: 56.sp,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/plants.jpg',
                              width: 56.sp,
                              height: 56.sp,
                              fit: BoxFit.cover,
                            );
                    },
                  )
                : disease.imageLink.isNotEmpty
                ? Image.network(
                    disease.imageLink[0],
                    width: 56.sp,
                    height: 56.sp,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/plants.jpg',
                    width: 56.sp,
                    height: 56.sp,
                    fit: BoxFit.cover,
                  ),
          ),
          title: Text(
            disease.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(disease.type),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF757575),
          ),
        ),
      ),
    );
  }
}
