import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/weather_card.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/home/sections/news_section.dart';
import 'package:se501_plantheon/presentation/screens/home/sections/history_section.dart';
import 'package:se501_plantheon/presentation/screens/home/sections/plants_section.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_provider.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_provider.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_provider.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_event.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_event.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_event.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return PlantProvider(
      child: ScanHistoryProvider(
        child: NewsProvider(size: 5, child: _HomeContent()),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  Future<void> _onRefresh() async {
    // Trigger refresh for all blocs
    context.read<NewsBloc>().add(FetchNewsEvent(size: 5));
    context.read<PlantBloc>().add(FetchPlantsEvent());
    context.read<ScanHistoryBloc>().add(GetAllScanHistoryEvent(size: 3));

    // Wait a bit for the APIs to complete
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary_main,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  WeatherCard(),
                  SizedBox(height: 12.sp),
                  PlantSection(),
                  HistorySection(),
                  SizedBox(height: 16.sp),
                  NewsSection(),
                  SizedBox(height: 30.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
