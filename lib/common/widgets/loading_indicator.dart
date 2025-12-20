import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rive/rive.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? padding;

  const LoadingIndicator({Key? key, this.size = 60, this.padding})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? EdgeInsets.all(10.sp),
        child: SizedBox(
          width: size.sp,
          height: size.sp,
          child: RiveAnimation.asset(
            'assets/animations/20330-38212-loading-green.riv',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
