import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/datepicker/basic_datepicker.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/domain/entities/guide_stage_entity.dart';
import 'package:se501_plantheon/domain/entities/plant_entity.dart';
import 'package:se501_plantheon/domain/usecases/guide_stage/get_guide_stage_detail.dart';
import 'package:se501_plantheon/presentation/bloc/guide_stage/guide_stage_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/guide_stage/guide_stage_event.dart';
import 'package:se501_plantheon/presentation/bloc/guide_stage/guide_stage_provider.dart';
import 'package:se501_plantheon/presentation/bloc/guide_stage/guide_stage_state.dart';
import 'package:se501_plantheon/presentation/bloc/guide_stage_detail/guide_stage_detail_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_provider.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_state.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/card/farming_tip_stage_card.dart';
import 'package:se501_plantheon/presentation/screens/home/widgets/plants_picker.dart';
import 'package:se501_plantheon/data/repository/guide_stage_repository_impl.dart';

class FarmingTips extends StatefulWidget {
  final PlantEntity? initialPlant;

  const FarmingTips({super.key, this.initialPlant});

  @override
  State<FarmingTips> createState() => _FarmingTipsState();
}

class _FarmingTipsState extends State<FarmingTips> {
  late DateTime _sowingDate;
  PlantEntity? _selectedPlant;
  BuildContext? _guideStageContext;
  bool _hasFetchedInitial = false;

  @override
  void initState() {
    super.initState();
    _sowingDate = DateTime.now();
    _selectedPlant = widget.initialPlant;
  }

  void _fetchGuideStages(String plantId, BuildContext ctx) {
    ctx.read<GuideStageBloc>().add(FetchGuideStagesEvent(plantId: plantId));
  }

  void _onPlantSelected(PlantEntity plant) {
    setState(() => _selectedPlant = plant);
    final ctx = _guideStageContext ?? context;
    _fetchGuideStages(plant.id, ctx);
  }

  void _onDateSelected(DateTime date) {
    setState(() => _sowingDate = date);
  }

  String _formatStageTime(GuideStageEntity stage) {
    final formatter = DateFormat('dd/MM/yyyy');
    final startDate = _sowingDate.add(Duration(days: stage.startDayOffset));
    final endDate = _sowingDate.add(Duration(days: stage.endDayOffset));
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  bool _isCurrentStage(GuideStageEntity stage) {
    final todayDiff = DateTime.now().difference(_sowingDate).inDays;
    if (todayDiff < 0) return false;
    return todayDiff >= stage.startDayOffset && todayDiff <= stage.endDayOffset;
  }

  @override
  Widget build(BuildContext context) {
    return PlantProvider(
      child: GuideStageProvider(
        child: Builder(
          builder: (context) {
            _guideStageContext = context;
            if (!_hasFetchedInitial && _selectedPlant != null) {
              _hasFetchedInitial = true;
              _fetchGuideStages(_selectedPlant!.id, context);
            }
            return BlocListener<PlantBloc, PlantState>(
              listenWhen: (previous, current) => current is PlantLoaded,
              listener: (context, state) {
                if (state is PlantLoaded &&
                    _selectedPlant == null &&
                    state.plants.isNotEmpty) {
                  final nextPlant = widget.initialPlant != null
                      ? state.plants.firstWhere(
                          (p) => p.id == widget.initialPlant!.id,
                          orElse: () => state.plants.first,
                        )
                      : state.plants.first;

                  setState(() => _selectedPlant = nextPlant);
                  _fetchGuideStages(nextPlant.id, context);
                }
              },
              child: Scaffold(
                appBar: BasicAppbar(title: 'Mẹo canh tác'),
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0.sp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4.sp,
                          children: [
                            Text(
                              "Ngày gieo:",
                              style: AppTextStyles.s14Medium(
                                color: AppColors.text_color_200,
                              ),
                            ),
                            Row(
                              spacing: 16.sp,
                              children: [
                                BasicDatepicker(
                                  initialDate: _sowingDate,
                                  onDateSelected: _onDateSelected,
                                ),
                                PlantsPicker(
                                  initialPlant: _selectedPlant,
                                  onPlantSelected: _onPlantSelected,
                                ),
                              ],
                            ),
                            SizedBox(height: 16.sp),
                          ],
                        ),
                      ),
                      BlocBuilder<GuideStageBloc, GuideStageState>(
                        builder: (context, state) {
                          if (_selectedPlant == null) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0.sp,
                              ),
                              child: Text(
                                'Hãy chọn cây trồng để xem lộ trình chăm sóc.',
                                style: AppTextStyles.s14Regular(
                                  color: AppColors.text_color_200,
                                ),
                              ),
                            );
                          }

                          if (state is GuideStageLoading) {
                            return const Center(child: LoadingIndicator());
                          }

                          if (state is GuideStageError) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0.sp,
                              ),
                              child: Text(
                                'Không tải được lộ trình: ${state.message}',
                                style: AppTextStyles.s14Regular(
                                  color: Colors.red,
                                ),
                              ),
                            );
                          }

                          if (state is GuideStageLoaded) {
                            if (state.stages.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.sp,
                                ),
                                child: Text(
                                  'Chưa có dữ liệu lộ trình cho cây này.',
                                  style: AppTextStyles.s14Regular(
                                    color: AppColors.text_color_200,
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: state.stages
                                  .map(
                                    (stage) =>
                                        BlocProvider<GuideStageDetailBloc>(
                                          create: (ctx) => GuideStageDetailBloc(
                                            getGuideStageDetail:
                                                GetGuideStageDetail(
                                                  repository: ctx
                                                      .read<
                                                        GuideStageRepositoryImpl
                                                      >(),
                                                ),
                                          ),
                                          child: FarmingTipStageCard(
                                            stageId: stage.id,
                                            imageUrl: stage.imageUrl,
                                            stageLabel: stage.stageTitle,
                                            stageDescription: stage.description,
                                            stageTime: _formatStageTime(stage),
                                            sowingDate: _sowingDate,
                                            isNow: _isCurrentStage(stage),
                                          ),
                                        ),
                                  )
                                  .toList(),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
