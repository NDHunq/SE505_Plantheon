import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/domain/usecases/activity/update_activity.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/data/datasources/activities_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/activities_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/activity/get_activities_by_month.dart';
import 'package:se501_plantheon/domain/usecases/activity/get_activities_by_day.dart';
import 'package:se501_plantheon/domain/usecases/activity/create_activity.dart';
import 'package:se501_plantheon/domain/usecases/activity/delete_activity.dart';
import 'package:se501_plantheon/presentation/bloc/activities/activities_bloc.dart';

class EditViewScreen extends StatefulWidget {
  final Widget contentWidget;
  final String? title;
  final VoidCallback? onCancel;
  // final VoidCallback? onSave;

  const EditViewScreen({
    super.key,
    required this.contentWidget,
    this.title,
    this.onCancel,
    // this.onSave,
  });

  @override
  State<EditViewScreen> createState() => _EditViewScreenState();
}

class _EditViewScreenState extends State<EditViewScreen> {
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
        padding: EdgeInsets.all(AppConstraints.mainPadding.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với nút Hủy và Lưu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: widget.onCancel ?? () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: TextStyle(color: Colors.red, fontSize: 16.sp),
                  ),
                ),
                Text(
                  widget.title ?? 'Chỉnh sửa',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 60.sp),
              ],
            ),

            // Nội dung được truyền vào
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(color: Colors.white),
                child: SingleChildScrollView(child: widget.contentWidget),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
