import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget tái sử dụng cho form row với label và child
class AddNewRow extends StatelessWidget {
  final String label;
  final Widget child;

  const AddNewRow({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.sp),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(label, style: TextStyle(fontSize: 12.sp)),
              ),
              Expanded(
                flex: 7,
                child: Align(alignment: Alignment.centerRight, child: child),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
