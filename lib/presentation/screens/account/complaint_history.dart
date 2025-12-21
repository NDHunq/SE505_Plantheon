import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/services/token_storage_service.dart';
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/datasources/complaint_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/complaint_repository_impl.dart';
import 'package:se501_plantheon/domain/entities/complaint_history_entity.dart';
import 'package:se501_plantheon/domain/usecases/complaint/submit_scan_complaint.dart';
import 'package:se501_plantheon/presentation/bloc/complaint/complaint_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/complaint/complaint_event.dart';
import 'package:se501_plantheon/presentation/bloc/complaint/complaint_state.dart';
import 'package:se501_plantheon/presentation/screens/community/post_detail.dart';
import 'package:se501_plantheon/presentation/screens/community/user_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/configs/assets/app_vectors.dart';

class ComplaintHistory extends StatelessWidget {
  const ComplaintHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: LoadingIndicator()));
        }
        final repository = ComplaintRepositoryImpl(
          remoteDataSource: ComplaintRemoteDataSourceImpl(
            client: http.Client(),
            baseUrl: ApiConstants.baseUrl,
            tokenStorage: TokenStorageService(prefs: snapshot.data!),
          ),
        );
        return BlocProvider(
          create: (context) => ComplaintBloc(
            submitScanComplaint: SubmitScanComplaint(repository: repository),
            complaintRepository: repository,
          )..add(FetchComplaintsAboutMeEvent()),
          child: const _ComplaintHistoryView(),
        );
      },
    );
  }
}

class _ComplaintHistoryView extends StatelessWidget {
  const _ComplaintHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(title: "Lịch sử báo cáo"),
      backgroundColor: Colors.grey[100],
      body: BlocBuilder<ComplaintBloc, ComplaintState>(
        builder: (context, state) {
          if (state is ComplaintsLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is ComplaintsLoadError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                    SizedBox(height: 16.sp),
                    Text(
                      'Không thể tải lịch sử báo cáo',
                      style: AppTextStyles.s16Bold(color: Colors.red),
                    ),
                    SizedBox(height: 8.sp),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.s12Regular(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16.sp),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ComplaintBloc>().add(
                          FetchComplaintsAboutMeEvent(),
                        );
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ComplaintsLoaded) {
            if (state.complaints.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppVectors.report,
                      width: 64.sp,
                      height: 64.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.sp),
                    Text(
                      'Chưa có báo cáo nào',
                      style: AppTextStyles.s16Bold(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8.sp),
                    Text(
                      'Các báo cáo về bài viết và bình luận của bạn\nsẽ hiển thị ở đây',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.s14Regular(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ComplaintBloc>().add(
                  FetchComplaintsAboutMeEvent(),
                );
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16.sp),
                itemCount: state.complaints.length,
                itemBuilder: (context, index) {
                  return _ComplaintCard(complaint: state.complaints[index]);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final ComplaintHistoryEntity complaint;

  const _ComplaintCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12.sp,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Type | Category | Spacer | Created Date
            Row(
              children: [
                _buildChip(
                  label: complaint.targetType == 'POST'
                      ? 'Bài viết'
                      : 'Bình luận',
                  backgroundColor: _getTypeColor(
                    complaint.targetType,
                  ).withOpacity(0.1),
                  textColor: _getTypeColor(complaint.targetType),
                ),
                SizedBox(width: 8.sp),
                _buildChip(
                  label: _getCategoryLabel(complaint.category),
                  backgroundColor: _getCategoryColor(
                    complaint.category,
                  ).withOpacity(0.1),
                  textColor: _getCategoryColor(complaint.category),
                ),
                Spacer(),
                Text(
                  _formatDateTime(complaint.createdAt),
                  style: AppTextStyles.s12Regular(color: Colors.grey[500]),
                ),
              ],
            ),
            SizedBox(height: 16.sp),

            // Body: Content Preview
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.sp),
              decoration: BoxDecoration(
                color: Colors.grey[50], // Very light grey bg for content
                borderRadius: BorderRadius.circular(12.sp),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: GestureDetector(
                onTap:
                    complaint.targetType == 'POST' &&
                        !complaint.target.isDeleted
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostDetail(postId: complaint.target.id),
                          ),
                        );
                      }
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfileScreen(
                                    userId: complaint.target.userId,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.sp,
                                vertical: 4.sp,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary_main.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6.sp),
                              ),
                              child: Text(
                                complaint.target.userName,
                                style: AppTextStyles.s14Bold(
                                  color: AppColors.primary_main,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        if (complaint.target.isDeleted) ...[
                          SizedBox(width: 8.sp),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.sp,
                              vertical: 2.sp,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.sp),
                            ),
                            child: Text(
                              'Đã xóa',
                              style: AppTextStyles.s10Medium(color: Colors.red),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 6.sp),
                    Text(
                      complaint.target.content,
                      style: AppTextStyles.s14Regular(
                        color: complaint.target.isDeleted
                            ? Colors.grey
                            : Colors.black87,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (complaint.targetType == 'POST' &&
                        !complaint.target.isDeleted)
                      Padding(
                        padding: EdgeInsets.only(top: 8.sp),
                        child: Row(
                          children: [
                            Text(
                              'Xem chi tiết',
                              style: AppTextStyles.s12Medium(
                                color: AppColors.primary_main,
                              ),
                            ),
                            SizedBox(width: 4.sp),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14.sp,
                              color: AppColors.primary_main,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.sp),

            // Footer: Status Badge + Resolved Date (if any)
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.sp,
                    vertical: 6.sp,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(complaint.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.sp), // Pill shape
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.sp,
                        height: 6.sp,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStatusColor(complaint.status),
                        ),
                      ),
                      SizedBox(width: 6.sp),
                      Text(
                        _getStatusLabel(complaint.status),
                        style: AppTextStyles.s12Medium(
                          color: _getStatusColor(complaint.status),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                if (complaint.resolvedAt != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14.sp,
                        color: AppColors.primary_main,
                      ),
                      SizedBox(width: 4.sp),
                      Text(
                        _formatDateTime(complaint.resolvedAt!),
                        style: AppTextStyles.s12Regular(
                          color: AppColors.primary_main,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Text(label, style: AppTextStyles.s12Medium(color: textColor)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'RESOLVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Đang chờ';
      case 'RESOLVED':
        return 'Đã xử lý';
      case 'REJECTED':
        return 'Đã từ chối';
      default:
        return status;
    }
  }

  Color _getTypeColor(String type) {
    return type == 'POST' ? Colors.blue : Colors.purple;
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'HARASSMENT':
        return Colors.red[800]!;
      case 'SPAM':
        return Colors.orange[800]!;
      case 'HATE_SPEECH':
        return Colors.red;
      case 'VIOLENCE':
        return Colors.deepOrange;
      case 'MISINFORMATION':
        return Colors.amber[800]!;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category.toUpperCase()) {
      case 'HARASSMENT':
        return 'Quấy rối';
      case 'SPAM':
        return 'Spam';
      case 'HATE_SPEECH':
        return 'Ngôn từ thù địch';
      case 'VIOLENCE':
        return 'Bạo lực';
      case 'MISINFORMATION':
        return 'Thông tin sai';
      default:
        return category;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
