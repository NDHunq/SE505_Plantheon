import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary_700, width: 1),
        ),
        child: Row(
          spacing: 16,
          children: [
            Text(
              _formattedDate,
              style: TextStyle(
                color: AppColors.text_color_200,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.calendar_month_rounded, color: AppColors.text_color_200),
          ],
        ),
      ),
    );
  }
}
