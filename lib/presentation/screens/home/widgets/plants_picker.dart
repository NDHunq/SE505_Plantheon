import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:se501_plantheon/domain/entities/plant_entity.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_state.dart';

class PlantsPicker extends StatefulWidget {
  final ValueChanged<PlantEntity>? onPlantSelected;
  final PlantEntity? initialPlant;

  const PlantsPicker({super.key, this.onPlantSelected, this.initialPlant});

  @override
  State<PlantsPicker> createState() => _PlantsPickerState();
}

class _PlantsPickerState extends State<PlantsPicker> {
  PlantEntity? _selectedPlant;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlantBloc, PlantState>(
      builder: (context, state) {
        if (state is PlantLoaded) {
          if (state.plants.isNotEmpty) {
            _selectedPlant ??= _pickInitial(state.plants);
            return _buildField(context, state.plants);
          }
          // Loaded nhưng rỗng
          return _container(
            child: Text(
              'Chưa có cây trồng',
              style: TextStyle(
                color: AppColors.text_color_200,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        if (state is PlantError) {
          return _container(
            child: const Text(
              'Không tải được danh sách cây',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        // PlantInitial / PlantLoading
        return _container(
          child: Row(
            spacing: 8.sp,
            children: [
              SizedBox(width: 16.sp, height: 16.sp, child: LoadingIndicator()),
              Text(
                'Đang tải...',
                style: TextStyle(color: AppColors.text_color_200, fontSize: 14.sp),
              ),
            ],
          ),
        );
      },
    );
  }

  PlantEntity _pickInitial(List<PlantEntity> plants) {
    if (widget.initialPlant != null) {
      final match = plants.firstWhere(
        (p) => p.id == widget.initialPlant!.id,
        orElse: () => plants.first,
      );
      return match;
    }
    return plants.first;
  }

  Widget _buildField(BuildContext context, List<PlantEntity> plants) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.sp),
      onTap: () async {
        final PlantEntity? picked = await showModalBottomSheet<PlantEntity>(
          context: context,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.sp)),
          ),
          builder: (context) => _PlantPickerSheet(
            plants: plants,
            initialSelectedId: _selectedPlant?.id,
          ),
        );

        if (picked != null) {
          setState(() => _selectedPlant = picked);
          widget.onPlantSelected?.call(picked);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.sp),
          border: Border.all(color: AppColors.primary_700, width: 1.sp),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8.sp,
          children: [
            _avatar(_selectedPlant?.imageUrl),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 180.sp, minWidth: 60.sp),
              child: Text(
                _selectedPlant?.name ?? 'Chọn cây trồng',
                style: TextStyle(
                  color: AppColors.text_color_main,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.sp),
      child: SizedBox(
        width: 40.sp,
        height: 40.sp,
        child: imageUrl != null && imageUrl.isNotEmpty
            ? (kIsWeb
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 16.sp,
                            height: 16.sp,
                            child: LoadingIndicator(),
                          ),
                        );
                      },
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          width: 16.sp,
                          height: 16.sp,
                          child: LoadingIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => _avatarFallback(),
                    ))
            : _avatarFallback(),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: AppColors.primary_50,
      child: const Icon(Icons.local_florist, color: AppColors.primary_400),
    );
  }

  Widget _container({required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
      constraints: BoxConstraints(minHeight: 44.sp, minWidth: 140.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: AppColors.primary_700, width: 1.sp),
      ),
      child: child,
    );
  }
}

class _PlantPickerSheet extends StatefulWidget {
  final List<PlantEntity> plants;
  final String? initialSelectedId;

  const _PlantPickerSheet({required this.plants, this.initialSelectedId});

  @override
  State<_PlantPickerSheet> createState() => _PlantPickerSheetState();
}

class _PlantPickerSheetState extends State<_PlantPickerSheet> {
  late List<PlantEntity> _filtered;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _filtered = widget.plants;
    _selectedId = widget.initialSelectedId;
  }

  void _filter(String query) {
    setState(() {
      _filtered = widget.plants
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.8.sp;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,

        borderRadius: BorderRadius.vertical(top: Radius.circular(24.sp)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.sp,
          right: 16.sp,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.sp,
          top: 16.sp,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.sp,
                height: 4.sp,
                decoration: BoxDecoration(
                  color: AppColors.text_color_100,
                  borderRadius: BorderRadius.circular(4.sp),
                ),
              ),
            ),
            SizedBox(height: 12.sp),
            Text(
              'Chọn cây trồng của bạn',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.text_color_main,
              ),
            ),
            SizedBox(height: 12.sp),
            TextField(
              onChanged: _filter,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Tìm kiếm',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.sp,
                  vertical: 10.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.sp),
                  borderSide: BorderSide(color: AppColors.text_color_100),
                ),
              ),
            ),
            SizedBox(height: 16.sp),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16.sp,
                  crossAxisSpacing: 16.sp,
                  childAspectRatio: 0.8,
                ),
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final plant = _filtered[index];
                  final selected = plant.id == _selectedId;
                  return _PlantItem(
                    plant: plant,
                    selected: selected,
                    onTap: () {
                      setState(() => _selectedId = plant.id);
                      Navigator.of(context).pop(plant);
                    },
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Hủy',
                  style: TextStyle(
                    color: AppColors.primary_700,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantItem extends StatelessWidget {
  final PlantEntity plant;
  final bool selected;
  final VoidCallback onTap;

  const _PlantItem({
    required this.plant,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96.sp,
            height: 96.sp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? AppColors.primary_700
                    : AppColors.text_color_100,
                width: selected ? 2.sp : 1.sp,
              ),
            ),
            child: ClipOval(
              child: (kIsWeb
                  ? Image.network(
                      plant.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.local_florist,
                        color: AppColors.primary_400,
                        size: 36.sp,
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: LoadingIndicator(),
                          ),
                        );
                      },
                    )
                  : CachedNetworkImage(
                      imageUrl: plant.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          width: 20.sp,
                          height: 20.sp,
                          child: LoadingIndicator(),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Icon(
                        Icons.local_florist,
                        color: AppColors.primary_400,
                        size: 36.sp,
                      ),
                    )),
            ),
          ),
          SizedBox(height: 8.sp),
          Text(
            plant.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text_color_main,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}