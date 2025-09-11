import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class BasicDatepicker extends StatelessWidget {
  const BasicDatepicker({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle date selection
        showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        ).then((selectedDate) {
          if (selectedDate != null) {
            // Update the selected date
          }
        });
      },
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
              "12/03/2024",
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
