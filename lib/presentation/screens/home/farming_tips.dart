import 'package:flutter/material.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/datepicker/basic_datepicker.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/farming_tip_stage_card.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/plants_dropdown.dart';

class FarmingTips extends StatelessWidget {
  const FarmingTips({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: 'Mẹo canh tác',
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary_700),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ngày gieo:",
                      style: TextStyle(
                        color: AppColors.text_color_200,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      spacing: 16,
                      children: [BasicDatepicker(), PlantsDropdown()],
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
              FarmingTipStageCard(
                vectorAsset: AppVectors.weatherSunny,
                stageLabel: 'Gieo trồng',
                stageDescription: 'Thời điểm thích hợp để gieo hạt giống.',
                stageTime: 'Ngày 1-7',
                isNow: false,
              ),
              FarmingTipStageCard(
                vectorAsset: AppVectors.weatherRainThunder,
                stageLabel: 'Gieo trồng',
                stageDescription: 'Thời điểm thích hợp để gieo hạt giống.',
                stageTime: 'Ngày 1-7',
                isNow: true,
                child: StageSection(),
              ),
              FarmingTipStageCard(
                vectorAsset: AppVectors.weatherSunny,
                stageLabel: 'Gieo trồng',
                stageDescription: 'Thời điểm thích hợp để gieo hạt giống.',
                stageTime: 'Ngày 1-7',
                isNow: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Giai đoạn 1: Gieo hạt",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary_700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Thời điểm thích hợp để gieo hạt giống.",
                      style: AppTextStyles.s14Regular(
                        color: AppColors.text_color_400,
                      ),
                    ),
                  ],
                ),
              ),
              FarmingTipStageCard(
                vectorAsset: AppVectors.weatherSunny,
                stageLabel: 'Gieo trồng',
                stageDescription: 'Thời điểm thích hợp để gieo hạt giống.',
                stageTime: 'Ngày 1-7',
                isNow: false,
              ),
              FarmingTipStageCard(
                vectorAsset: AppVectors.weatherSunny,
                stageLabel: 'Gieo trồng',
                stageDescription: 'Thời điểm thích hợp để gieo hạt giống.',
                stageTime: 'Ngày 1-7',
                isNow: false,
              ),
              FarmingTipStageCard(
                vectorAsset: AppVectors.weatherSunny,
                stageLabel: 'Gieo trồng',
                stageDescription: 'Thời điểm thích hợp để gieo hạt giống.',
                stageTime: 'Ngày 1-7',
                isNow: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StageSection extends StatelessWidget {
  const StageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          "Tuần 1",
          style: AppTextStyles.s16SemiBold(color: AppColors.primary_700),
        ),
        Text(
          "07/08/2025 - 14/08/2025",
          style: AppTextStyles.s14Regular(color: AppColors.text_color_400),
        ),
      ],
    );
  }
}
