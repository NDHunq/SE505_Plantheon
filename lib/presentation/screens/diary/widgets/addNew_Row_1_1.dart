import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget với text ở một row và text field ở một row riêng biệt
class AddNewRowVertical extends StatelessWidget {
  final String label;
  final Widget child;

  const AddNewRowVertical({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row cho label
        Padding(
          padding: EdgeInsets.fromLTRB(0.sp, 8.sp, 0.sp, 0.sp),
          child: Row(
            children: [Text(label, style: TextStyle(fontSize: 14.sp))],
          ),
        ),
        // Row cho child (text field)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.sp),
          child: Row(children: [Expanded(child: child)]),
        ),
      ],
    );
  }
}
