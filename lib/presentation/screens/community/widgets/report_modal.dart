import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/data/datasources/complaint_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/auth_repository_impl.dart';
import 'package:se501_plantheon/data/repository/complaint_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/complaint/submit_scan_complaint.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/complaint/complaint_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/complaint/complaint_event.dart';
import 'package:se501_plantheon/presentation/bloc/complaint/complaint_state.dart';
import 'package:toastification/toastification.dart';

class ReportModal extends StatefulWidget {
  final String targetId;
  final String targetType; // "POST" or "COMMENT"

  const ReportModal({
    super.key,
    required this.targetId,
    required this.targetType,
  });

  static void show(BuildContext context, String targetId, String targetType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ReportModal(targetId: targetId, targetType: targetType),
    );
  }

  @override
  State<ReportModal> createState() => _ReportModalState();
}

class _ReportModalState extends State<ReportModal> {
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'value': 'SPAM', 'label': 'Spam'},
    {'value': 'HARASSMENT', 'label': 'Quấy rối'},
    {'value': 'INAPPROPRIATE', 'label': 'Nội dung không phù hợp'},
    {'value': 'MISINFORMATION', 'label': 'Thông tin sai lệch'},
    {'value': 'OTHER', 'label': 'Khác'},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Capture AuthBloc from parent context BEFORE creating BlocProvider
    final authBloc = context.read<AuthBloc>();

    final repository = ComplaintRepositoryImpl(
      remoteDataSource: ComplaintRemoteDataSourceImpl(
        client: http.Client(),
        baseUrl: ApiConstants.baseUrl,
        tokenStorage:
            (authBloc.authRepository as AuthRepositoryImpl).tokenStorage,
      ),
    );

    return BlocProvider(
      create: (_) => ComplaintBloc(
        submitScanComplaint: SubmitScanComplaint(repository: repository),
        complaintRepository: repository,
      ),
      child: Builder(
        builder: (context) {
          return BlocListener<ComplaintBloc, ComplaintState>(
            listener: (context, state) {
              if (state is ComplaintSubmitted) {
                Navigator.of(context).pop();
                toastification.show(
                  context: context,
                  type: ToastificationType.success,
                  style: ToastificationStyle.flat,
                  title: const Text('Báo cáo đã được gửi thành công'),
                  autoCloseDuration: const Duration(seconds: 3),
                  alignment: Alignment.bottomCenter,
                  showProgressBar: true,
                );
              } else if (state is ComplaintError) {
                toastification.show(
                  context: context,
                  type: ToastificationType.error,
                  style: ToastificationStyle.flat,
                  title: Text('Lỗi: ${state.message}'),
                  autoCloseDuration: const Duration(seconds: 3),
                  alignment: Alignment.bottomCenter,
                  showProgressBar: true,
                );
              }
            },
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.sp),
                  topRight: Radius.circular(20.sp),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Báo cáo ${widget.targetType == "POST" ? "bài viết" : "bình luận"}',
                          style: AppTextStyles.s16Bold(),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.sp),

                    // Category dropdown
                    Text('Loại vi phạm', style: AppTextStyles.s14SemiBold()),
                    SizedBox(height: 8.sp),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.sp),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          hint: Text(
                            'Chọn loại vi phạm',
                            style: AppTextStyles.s14Regular(
                              color: Colors.grey[600],
                            ),
                          ),
                          isExpanded: true,
                          items: _categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category['value'],
                              child: Text(
                                category['label']!,
                                style: AppTextStyles.s14Regular(),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16.sp),

                    // Description text field
                    Text('Mô tả chi tiết', style: AppTextStyles.s14SemiBold()),
                    SizedBox(height: 8.sp),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 0.sp,
                        vertical: 8.sp,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Vui lòng mô tả chi tiết về vi phạm...',
                          border: InputBorder.none,
                          hintStyle: AppTextStyles.s14Regular(
                            color: Colors.grey[600],
                          ),
                        ),
                        style: AppTextStyles.s14Regular(),
                      ),
                    ),
                    SizedBox(height: 24.sp),

                    // Action buttons
                    BlocBuilder<ComplaintBloc, ComplaintState>(
                      builder: (context, state) {
                        final isSubmitting = state is ComplaintSubmitting;

                        return Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12.sp,
                                  ),
                                  side: BorderSide(color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                ),
                                child: Text(
                                  'Hủy',
                                  style: AppTextStyles.s14SemiBold(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.sp),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => _submitComplaint(context),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12.sp,
                                  ),
                                  backgroundColor: AppColors.primary_main,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                ),
                                child: isSubmitting
                                    ? SizedBox(
                                        height: 20.sp,
                                        width: 20.sp,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'Gửi báo cáo',
                                        style: AppTextStyles.s14SemiBold(
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitComplaint(BuildContext blocContext) {
    // Validation
    if (_selectedCategory == null) {
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        style: ToastificationStyle.flat,
        title: const Text('Vui lòng chọn loại vi phạm'),
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.bottomCenter,
        showProgressBar: true,
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        style: ToastificationStyle.flat,
        title: const Text('Vui lòng mô tả chi tiết về vi phạm'),
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.bottomCenter,
        showProgressBar: true,
      );
      return;
    }

    // Submit complaint using the correct context from Builder
    blocContext.read<ComplaintBloc>().add(
      SubmitComplaintEvent(
        targetId: widget.targetId,
        targetType: widget.targetType,
        category: _selectedCategory!,
        content: _descriptionController.text.trim(),
      ),
    );
  }
}
