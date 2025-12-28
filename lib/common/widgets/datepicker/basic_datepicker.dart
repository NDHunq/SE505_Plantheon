import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:intl/intl.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class BasicDatepicker extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateSelected;

  const BasicDatepicker({super.key, this.initialDate, this.onDateSelected});

  @override
  State<BasicDatepicker> createState() => _BasicDatepickerState();
}

class _BasicDatepickerState extends State<BasicDatepicker> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  String get _formattedDate => DateFormat('dd/MM/yyyy').format(_selectedDate);

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.sp),
          border: Border.all(color: AppColors.primary_600, width: 1.sp),
        ),
        child: Row(
          spacing: 12.sp,
          children: [
            Text(
              _formattedDate,
              style: TextStyle(
                color: AppColors.primary_600,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SvgPicture.asset(
              AppVectors.calendar,
              width: 24.sp,
              height: 24.sp,
              color: AppColors.primary_600,
            ),
          ],
        ),
      ),
    );
  }
}
