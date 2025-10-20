import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/presentation/screens/diary/banSanPham.dart';
import 'package:se501_plantheon/presentation/screens/diary/chiTieu.dart';
import 'package:se501_plantheon/presentation/screens/diary/climamate.dart';
import 'package:se501_plantheon/presentation/screens/diary/dichBenh.dart';
import 'package:se501_plantheon/presentation/screens/diary/kyThuat.dart';
import 'package:se501_plantheon/presentation/screens/diary/other.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/data/datasources/activities_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/activities_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/get_activities_by_month.dart';
import 'package:se501_plantheon/domain/usecases/get_activities_by_day.dart';
import 'package:se501_plantheon/domain/usecases/create_activity.dart';
import 'package:se501_plantheon/domain/usecases/update_activity.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_bloc.dart';

class AddNewScreen extends StatefulWidget {
  final DateTime? initialDate;

  const AddNewScreen({super.key, this.initialDate});

  @override
  State<AddNewScreen> createState() => _AddNewScreenState();
}

class _AddNewScreenState extends State<AddNewScreen> {
  String? selectedCategory;
  bool showCategorySelection = true;

  final List<Map<String, dynamic>> categories = [
    {'id': 'targets', 'title': 'Chỉ tiêu', 'icon': Icons.track_changes},
    {
      'id': 'sales',
      'title': 'Bán sản phẩm, vật tư',
      'icon': Icons.shopping_cart,
    },
    {'id': 'disasters', 'title': 'Dịch bệnh thiên tai', 'icon': Icons.warning},
    {'id': 'techniques', 'title': 'Kỹ thuật chăm sóc', 'icon': Icons.science},
    {
      'id': 'climate',
      'title': 'Thích ứng với BĐKH và mô...',
      'icon': Icons.cloud,
    },
    {'id': 'other', 'title': 'Khác', 'icon': Icons.more_horiz},
  ];

  Widget _buildCategoryContent() {
    switch (selectedCategory) {
      case 'targets':
        return chiTieuWidget(initialDate: widget.initialDate);
      case 'sales':
        return banSanPhamWidget(initialDate: widget.initialDate);
      case 'disasters':
        return dichBenhWidget(initialDate: widget.initialDate);
      case 'techniques':
        return kyThuatWidget(initialDate: widget.initialDate);
      case 'climate':
        return climateWidget();
      case 'other':
        return const otherWidget();
      default:
        return const SizedBox.shrink();
    }
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
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstraints.mainPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với nút Hủy/Quay lại và Thêm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    if (showCategorySelection) {
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        showCategorySelection = true;
                        selectedCategory = null;
                      });
                    }
                  },
                  child: Text(
                    showCategorySelection ? 'Hủy' : 'Quay lại',
                    style: TextStyle(
                      color: showCategorySelection ? Colors.red : Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Text(
                  'Thêm mới',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 60),
              ],
            ),
            const SizedBox(height: 20),

            // Hiển thị subtitle và grid khi chưa chọn category
            if (showCategorySelection) ...[
              // Subtitle
              const Text(
                'Chọn chủ đề cho nhật ký hôm nay',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),

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
                    final isSelected = selectedCategory == category['id'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category['id'];
                          showCategorySelection = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Colors.purple
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category['icon'],
                              size: 32,
                              color: isSelected ? Colors.purple : Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                category['title'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.purple
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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

            // Nội dung được chọn
            if (!showCategorySelection && selectedCategory != null) ...[
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(child: _buildCategoryContent()),
                ),
              ),
            ],
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
