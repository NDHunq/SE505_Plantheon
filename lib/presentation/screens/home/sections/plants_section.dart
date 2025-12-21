import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_state.dart';
import 'package:se501_plantheon/presentation/screens/home/farming_tips.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/plants_card.dart';

class PlantSection extends StatelessWidget {
  const PlantSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4.sp,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mẹo canh tác',
              style: AppTextStyles.s16Medium(color: AppColors.primary_700),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FarmingTips()),
                );
              },
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: AppColors.primary_700,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 114.sp,
          child: BlocBuilder<PlantBloc, PlantState>(
            builder: (context, state) {
              final isLoading = state is PlantLoading || state is PlantInitial;

              if (state is PlantError) {
                return Center(
                  child: Text(
                    'Không thể tải danh sách cây trồng',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              final plants = state is PlantLoaded ? state.plants : [];

              if (!isLoading && plants.isEmpty) {
                return const Center(
                  child: Text('Chưa có cây trồng để hiển thị'),
                );
              }

              // Show skeleton or real data
              final displayPlants = isLoading
                  ? List.generate(4, (index) => null) // 4 skeleton items
                  : plants;

              return Skeletonizer(
                enabled: isLoading,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayPlants.length,
                  itemBuilder: (context, index) {
                    if (isLoading) {
                      // Skeleton card
                      return const PlantsCard(name: 'Plant Name', imageUrl: '');
                    }

                    final plant = plants[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FarmingTips(initialPlant: plant),
                          ),
                        );
                      },
                      child: PlantsCard(
                        name: plant.name,
                        imageUrl: plant.imageUrl,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
