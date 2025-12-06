import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_state.dart';
import 'package:se501_plantheon/presentation/screens/home/farming_tips.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/service_card.dart';

class PlantSection extends StatelessWidget {
  const PlantSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.sp,
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
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColors.primary_700,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 100.sp,
          child: BlocBuilder<PlantBloc, PlantState>(
            builder: (context, state) {
              if (state is PlantLoading || state is PlantInitial) {
                return const Center(child: LoadingIndicator());
              }

              if (state is PlantError) {
                return Center(
                  child: Text(
                    'Không thể tải danh sách cây trồng',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              if (state is PlantLoaded) {
                if (state.plants.isEmpty) {
                  return const Center(
                    child: Text('Chưa có cây trồng để hiển thị'),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.plants.length,
                  itemBuilder: (context, index) {
                    final plant = state.plants[index];
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
                      child: ServiceCard(
                        name: plant.name,
                        imageUrl: plant.imageUrl,
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
