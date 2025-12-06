import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/domain/entities/plant_entity.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_state.dart';

/// Field that opens a bottom sheet to pick a plant (with search + grid).
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
            child: const Text(
              'Chưa có cây trồng',
              style: TextStyle(
                color: AppColors.text_color_200,
                fontSize: 14,
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
            spacing: 8,
            children: const [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              Text(
                'Đang tải...',
                style: TextStyle(color: AppColors.text_color_200, fontSize: 14),
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
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final PlantEntity? picked = await showModalBottomSheet<PlantEntity>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary_700, width: 1),
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
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 40,
        height: 40,
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarFallback(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              )
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      constraints: const BoxConstraints(minHeight: 44, minWidth: 140),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary_700, width: 1),
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
    final height = MediaQuery.of(context).size.height * 0.8;
    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.text_color_100,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Chọn cây trồng của bạn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text_color_main,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: _filter,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Tìm kiếm',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.text_color_100),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
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
                child: const Text('Hủy'),
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
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? AppColors.primary_700
                    : AppColors.text_color_100,
                width: selected ? 2 : 1,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                plant.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.local_florist,
                  color: AppColors.primary_400,
                  size: 36,
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plant.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
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
