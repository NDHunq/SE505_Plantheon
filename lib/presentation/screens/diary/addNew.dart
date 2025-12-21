import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/assets/app_images.dart';
import 'package:se501_plantheon/presentation/screens/diary/banSanPham.dart';
import 'package:se501_plantheon/presentation/screens/diary/chiTieu.dart';
import 'package:se501_plantheon/presentation/screens/diary/climamate.dart';
import 'package:se501_plantheon/presentation/screens/diary/dichBenh.dart';
import 'package:se501_plantheon/presentation/screens/diary/kyThuat.dart';
import 'package:se501_plantheon/presentation/screens/diary/other.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/data/datasources/activities_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/activities_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/activity/get_activities_by_month.dart';
import 'package:se501_plantheon/domain/usecases/activity/get_activities_by_day.dart';
import 'package:se501_plantheon/domain/usecases/activity/create_activity.dart';
import 'package:se501_plantheon/domain/usecases/activity/update_activity.dart';
import 'package:se501_plantheon/domain/usecases/activity/delete_activity.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_bloc.dart';

class AddNewScreen extends StatefulWidget {
  final DateTime? initialDate;
  final VoidCallback? onActivitySaved;

  const AddNewScreen({super.key, this.initialDate, this.onActivitySaved});

  @override
  State<AddNewScreen> createState() => _AddNewScreenState();
}

class _AddNewScreenState extends State<AddNewScreen>
    with SingleTickerProviderStateMixin {
  String? selectedCategory;
  bool showCategorySelection =
      true; // This might become redundant or its usage needs to be aligned with selectedCategory != null

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> categories = [
    {
      'id': 'targets',
      'title': 'Chỉ tiêu',
      'icon': Icons.track_changes,
      'image':
          AppImages.expense, // Using expense as placeholder/appropriate image
    },
    {
      'id': 'sales',
      'title': 'Bán sản phẩm, vật tư',
      'icon': Icons.shopping_cart,
      'image':
          AppImages.income, // Using income as placeholder/appropriate image
    },
    {
      'id': 'disasters',
      'title': 'Dịch bệnh thiên tai',
      'icon': Icons.warning,
      'image': AppImages.disease,
    },
    {
      'id': 'techniques',
      'title': 'Kỹ thuật chăm sóc',
      'icon': Icons.science,
      'image': AppImages.technique,
    },
    {
      'id': 'climate',
      'title': 'Thích ứng BĐKH & MT',
      'icon': Icons.cloud,
      'image': AppImages.climate,
    },
    {
      'id': 'other',
      'title': 'Khác',
      'icon': Icons.more_horiz,
      'image': AppImages.other,
    },
  ];

  Widget _buildCategoryContent() {
    switch (selectedCategory) {
      case 'targets':
        return chiTieuWidget(
          initialDate: widget.initialDate,
          onSubmitSuccess: widget.onActivitySaved,
        );
      case 'sales':
        return banSanPhamWidget(
          initialDate: widget.initialDate,
          onSubmitSuccess: widget.onActivitySaved,
        );
      case 'disasters':
        return dichBenhWidget(
          initialDate: widget.initialDate,
          onSubmitSuccess: widget.onActivitySaved,
        );
      case 'techniques':
        return kyThuatWidget(
          initialDate: widget.initialDate,
          onSubmitSuccess: widget.onActivitySaved,
        );
      case 'climate':
        return climaMateWidget(
          initialDate: widget.initialDate,
          onSubmitSuccess: widget.onActivitySaved,
        );
      case 'other':
        return otherWidget(
          initialDate: widget.initialDate,
          onSubmitSuccess: widget.onActivitySaved,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSelectedCategoryView() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(color: Colors.white),
      child: SingleChildScrollView(child: _buildCategoryContent()),
    );
  }

  Widget _buildCategoriesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle
        SizedBox(height: 16.sp),
        Center(
          child: Text(
            'Chọn chủ đề cho nhật ký hôm nay',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        ),
        SizedBox(height: 16.sp),

        // Grid 6 mục
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              // final isSelected = selectedCategory == category['id']; // This is now handled by the outer selectedCategory check

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category['id'];
                    _animationController.forward();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedCategory == category['id']
                        ? Color(0xFFE6F4EA)
                        : Colors.grey[50], // Lighter grey for better look
                    borderRadius: BorderRadius.circular(16.sp),
                    border: Border.all(
                      color: selectedCategory == category['id']
                          ? AppColors.primary_600
                          : Colors.transparent,
                      width: 2.sp,
                    ),
                    boxShadow: [
                      if (selectedCategory != category['id'])
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4.sp,
                          offset: Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      category['image'] != null
                          ? Image.asset(
                              category['image'],
                              width: 80.sp, // Increased size
                              height: 80.sp,
                              fit: BoxFit.contain,
                            )
                          : Icon(
                              category['icon'],
                              size: 64.sp, // Increased icon size
                              color: selectedCategory == category['id']
                                  ? AppColors.primary_600
                                  : Colors.grey[600],
                            ),
                      SizedBox(height: 24.sp),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.sp),
                        child: Text(
                          category['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp, // Slightly bigger text
                            color: selectedCategory == category['id']
                                ? AppColors.primary_600
                                : Colors.black87,
                            fontWeight: selectedCategory == category['id']
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repository = ActivitiesRepositoryImpl(
          remoteDataSource: ActivitiesRemoteDataSourceImpl(
            client: http.Client(),
          ),
        );
        return ActivitiesBloc(
          getActivitiesByMonth: GetActivitiesByMonth(repository),
          getActivitiesByDay: GetActivitiesByDay(repository),
          createActivity: CreateActivity(repository),
          updateActivity: UpdateActivity(repository),
          deleteActivity: DeleteActivity(repository),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36.sp,
                height: 4.sp,
                margin: EdgeInsets.symmetric(vertical: 8.sp),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.sp),
                ),
              ),
            ),
            // Header Row
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0.sp,
                vertical: 8.0.sp,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (selectedCategory != null) {
                        setState(() {
                          selectedCategory = null;
                          _animationController.reverse();
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 0.sp,
                        horizontal: 4.sp,
                      ),
                      color: Colors.transparent,
                      child: selectedCategory != null
                          ? Icon(Icons.arrow_back, size: 20.sp)
                          : Text(
                              'Hủy',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  Text(
                    'Thêm mới',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Empty container for balance
                  SizedBox(width: 36.sp),
                ],
              ),
            ),

            Expanded(
              child: selectedCategory != null
                  ? _buildSelectedCategoryView()
                  : _buildCategoriesGrid(),
            ),
          ],
        ),
      ),
    );
  }
}

class SalesWidget extends StatelessWidget {
  const SalesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Widget Bán sản phẩm, vật tư'),
        Text('Bạn có thể tự định nghĩa nội dung ở đây'),
      ],
    );
  }
}

class DisastersWidget extends StatelessWidget {
  const DisastersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Widget Dịch bệnh thiên tai'),
        Text('Bạn có thể tự định nghĩa nội dung ở đây'),
      ],
    );
  }
}

class TechniquesWidget extends StatelessWidget {
  const TechniquesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Widget Kỹ thuật chăm sóc'),
        Text('Bạn có thể tự định nghĩa nội dung ở đây'),
      ],
    );
  }
}

class ClimateWidget extends StatelessWidget {
  const ClimateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Widget Thích ứng với BĐKH'),
        Text('Bạn có thể tự định nghĩa nội dung ở đây'),
      ],
    );
  }
}

class OtherWidget extends StatelessWidget {
  const OtherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Widget Khác'),
        Text('Bạn có thể tự định nghĩa nội dung ở đây'),
      ],
    );
  }
}
