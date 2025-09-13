import 'package:flutter/material.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/datepicker/basic_datepicker.dart';
import 'package:se501_plantheon/common/widgets/divider/dash_divider.dart';
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
                child: Column(
                  children: [
                    StageSection(),
                    DashDivider(),
                    StageSection(),
                    DashDivider(),
                    StageSection(),
                  ],
                ),
              ),
              FarmingTipStageCard(
                vectorAsset: AppVectors.weatherSunny,
                stageLabel: 'Gieo trồng',
                stageDescription: 'Thời điểm thích hợp để gieo hạt giống.',
                stageTime: 'Ngày 1-7',
                isNow: false,
                child: Column(
                  children: [
                    StageSection(),
                    DashDivider(),
                    StageSection(),
                    DashDivider(),
                    StageSection(),
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
    return Container(
      decoration: BoxDecoration(color: AppColors.white),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    "Tuần 1",
                    style: AppTextStyles.s16SemiBold(
                      color: AppColors.primary_700,
                    ),
                  ),
                  Text(
                    "07/08/2025 - 14/08/2025",
                    style: AppTextStyles.s14Regular(
                      color: AppColors.text_color_400,
                    ),
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      separatorBuilder: (context, index) => SizedBox(width: 8),
                      itemBuilder: (context, index) => StagePreviewCard(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StagePreviewCard extends StatelessWidget {
  const StagePreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: AppColors.white,

        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.text_color_50, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 69,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage('assets/images/plants.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary_100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Làm cỏ",
                    style: AppTextStyles.s12Medium(
                      color: AppColors.primary_700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "Những điều cần biết về việc chăm sóc cây trồng trong giai đoạn đầu.",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.text_color_400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
