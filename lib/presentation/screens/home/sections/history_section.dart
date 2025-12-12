import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_event.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_provider.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_state.dart';
import 'package:se501_plantheon/presentation/screens/home/scan_history.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/history_card.dart';
import 'package:intl/intl.dart';
import 'package:se501_plantheon/presentation/screens/scan/scan_solution.dart';

class HistorySection extends StatefulWidget {
  const HistorySection({super.key});

  @override
  State<HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<HistorySection> {
  @override
  void initState() {
    super.initState();
    // Dispatch event to fetch 3 scan history items
    context.read<ScanHistoryBloc>().add(GetAllScanHistoryEvent(size: 3));
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.sp,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lịch sử quét bệnh',
              style: AppTextStyles.s16Medium(color: AppColors.primary_700),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanHistory()),
                );
              },
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.primary_700,
              ),
            ),
          ],
        ),
        BlocBuilder<ScanHistoryBloc, ScanHistoryState>(
          builder: (context, state) {
            final isLoading = state is ScanHistoryLoading;

            if (state is ScanHistoryError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Text(
                    'Lỗi: ${state.message}',
                    style: AppTextStyles.s14Regular(color: Colors.red),
                  ),
                ),
              );
            }

            final scanHistories = state is ScanHistorySuccess
                ? state.scanHistories
                : [];

            if (!isLoading && scanHistories.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Text(
                    'Chưa có lịch sử quét bệnh',
                    style: AppTextStyles.s14Regular(
                      color: AppColors.text_color_300,
                    ),
                  ),
                ),
              );
            }

            // Show skeleton or real data
            final displayItems = isLoading
                ? List.generate(3, (index) => null) // 3 skeleton items
                : scanHistories;

            return Skeletonizer(
              enabled: isLoading,
              child: Column(
                children: List.generate(displayItems.length, (index) {
                  if (isLoading) {
                    // Skeleton card
                    return Column(
                      children: [
                        if (index > 0)
                          Divider(
                            height: 16.sp,
                            color: AppColors.text_color_100,
                            thickness: 1.sp,
                          ),
                        const HistoryCard(
                          title: 'Disease Name Loading',
                          dateTime: '01/01/2024 12:00',
                          isSuccess: true,
                          scanImageUrl: '',
                        ),
                      ],
                    );
                  }

                  final scanHistory = scanHistories[index];
                  final disease = scanHistory.disease;

                  return Column(
                    children: [
                      if (index > 0)
                        Divider(
                          height: 16.sp,
                          color: AppColors.text_color_100,
                          thickness: 1.sp,
                        ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScanHistoryProvider(
                                child: ScanSolution(
                                  scanHistoryId: scanHistory.id,
                                ),
                              ),
                            ),
                          );
                        },
                        child: HistoryCard(
                          title: disease.name,
                          dateTime: _formatDateTime(scanHistory.createdAt),
                          isSuccess: true,
                          scanImageUrl:
                              scanHistory.scanImage ??
                              'https://via.placeholder.com/150',
                        ),
                      ),
                    ],
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }
}
