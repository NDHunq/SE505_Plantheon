import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_event.dart';
import 'package:se501_plantheon/presentation/bloc/keyword_activities/keyword_activities_state.dart';
import 'package:se501_plantheon/domain/entities/keyword_activity_entity.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/presentation/screens/scan/widgets/reusable_activity_suggestion_item.dart';
import 'package:se501_plantheon/presentation/screens/scan/models/activity_ui_model.dart';

class ActivitiesSuggestionList extends StatelessWidget {
  final String diseaseId;

  const ActivitiesSuggestionList({super.key, required this.diseaseId});

  ActivityType _mapTypeToActivityType(String type) {
    switch (type.toUpperCase()) {
      case 'EXPENSE':
        return ActivityType.chiTieu;
      case 'INCOME':
        return ActivityType.banSanPham;
      case 'TECHNIQUE':
        return ActivityType.kyThuat;
      case 'DISEASE':
        return ActivityType.dichBenh;
      case 'CLIMATE':
        return ActivityType.kinhKhi;
      case 'OTHER':
      default:
        return ActivityType.khac;
    }
  }

  DateTime _calculateStartTime(KeywordActivityEntity keywordActivity) {
    final now = DateTime.now();
    final baseDate = now.add(Duration(days: keywordActivity.baseDaysOffset));

    // Luôn dùng hour_time từ database
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      keywordActivity.hourTime,
      0,
    );
  }

  DateTime _calculateEndTime(KeywordActivityEntity keywordActivity) {
    final now = DateTime.now();
    final baseDate = now.add(Duration(days: keywordActivity.baseDaysOffset));

    // Luôn dùng end_hour_time từ database
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      keywordActivity.endHourTime,
      0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KeywordActivitiesBloc, KeywordActivitiesState>(
      builder: (context, state) {
        if (state is KeywordActivitiesLoading) {
          return const LoadingIndicator();
        }

        if (state is KeywordActivitiesError) {
          // Check if it's a 404 error
          final is404 = state.message.contains('404');

          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.sp),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    is404 ? Icons.cloud_off_outlined : Icons.error_outline,
                    size: 48.sp,
                    color: is404 ? Colors.orange : Colors.red,
                  ),
                  SizedBox(height: 12.sp),
                  Text(
                    is404 ? 'API chưa sẵn sàng' : 'Lỗi khi tải dữ liệu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: is404 ? Colors.orange : Colors.red,
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  Text(
                    is404
                        ? 'Endpoint /keyword-activities/disease/{id}\nchưa được triển khai trên backend'
                        : state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.sp),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<KeywordActivitiesBloc>().add(
                        FetchKeywordActivities(diseaseId: diseaseId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is KeywordActivitiesLoaded) {
          if (state.activities.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.sp),
                child: Text(
                  'Không có hoạt động gợi ý',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          final activities = state.activities.map((keywordActivity) {
            return Activity(
              title: keywordActivity.name,
              description: keywordActivity.description,
              type: _mapTypeToActivityType(keywordActivity.type),
              suggestedTime: _calculateStartTime(keywordActivity),
              endTime: _calculateEndTime(keywordActivity),
              originalEntity: keywordActivity,
            );
          }).toList();

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return ReusableActivitySuggestionItem(
                activity: activities[index],
              );
            },
            separatorBuilder: (context, index) => SizedBox(height: 12.sp),
          );
        }

        // Initial state
        return const SizedBox.shrink();
      },
    );
  }
}