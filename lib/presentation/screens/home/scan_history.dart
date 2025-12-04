import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/dialog/basic_dialog.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/data/datasources/scan_history_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/scan_history_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/get_all_scan_history.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/get_scan_history_by_id.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/create_scan_history.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/delete_all_scan_history.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/delete_scan_history_by_id.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_event.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_state.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_provider.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/history_card.dart';
import 'package:se501_plantheon/presentation/screens/scan/scan_solution.dart';

class ScanHistory extends StatelessWidget {
  const ScanHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repository = ScanHistoryRepositoryImpl(
          remoteDataSource: ScanHistoryRemoteDataSourceImpl(
            client: http.Client(),
            baseUrl: ApiConstants.baseUrl,
          ),
        );
        return ScanHistoryBloc(
          getAllScanHistory: GetAllScanHistory(repository: repository),
          getScanHistoryById: GetScanHistoryById(repository: repository),
          createScanHistory: CreateScanHistory(repository: repository),
          deleteAllScanHistory: DeleteAllScanHistory(repository: repository),
          deleteScanHistoryById: DeleteScanHistoryById(repository: repository),
        )..add(GetAllScanHistoryEvent());
      },
      child: const _ScanHistoryContent(),
    );
  }
}

class _ScanHistoryContent extends StatelessWidget {
  const _ScanHistoryContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: 'Lịch sử quét bệnh',
        actions: [
          BlocBuilder<ScanHistoryBloc, ScanHistoryState>(
            builder: (context, state) {
              if (state is ScanHistorySuccess &&
                  state.scanHistories.isNotEmpty) {
                return IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => BasicDialog(
                        title: "Xóa lịch sử quét bệnh",
                        content:
                            "Bạn có chắc chắn muốn xóa tất cả lịch sử quét bệnh?",
                        onConfirm: () {
                          // TODO: Implement delete all scan history
                          Navigator.of(context).pop();
                        },
                        onCancel: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                  icon: SvgPicture.asset(
                    AppVectors.trash,
                    width: 24.sp,
                    height: 24.sp,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
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
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${state.message}',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ScanHistoryBloc>().add(
                        GetAllScanHistoryEvent(),
                      );
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          } else if (state is ScanHistorySuccess) {
            if (state.scanHistories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có lịch sử quét bệnh',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: ListView.separated(
                itemCount: state.scanHistories.length,
                separatorBuilder: (context, index) => Divider(
                  height: 16.sp,
                  color: AppColors.text_color_100,
                  thickness: 1.sp,
                ),
                itemBuilder: (context, index) {
                  final scanHistory = state.scanHistories[index];
                  final disease = scanHistory.disease;

                  return Dismissible(
                    key: ValueKey(scanHistory.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 20.sp),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      // TODO: Implement delete single scan history
                    },
                    child: GestureDetector(
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
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
