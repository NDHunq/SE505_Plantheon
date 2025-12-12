import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class FastLottieLoading extends StatefulWidget {
  final String assetPath;
  final double width;
  final double height;
  final double speed;

  const FastLottieLoading({
    Key? key,
    required this.assetPath,
    this.width = 200,
    this.height = 200,
    this.speed = 2.0,
  }) : super(key: key);

  @override
  State<FastLottieLoading> createState() => _FastLottieLoadingState();
}

class _FastLottieLoadingState extends State<FastLottieLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.assetPath,
      width: widget.width.sp,
      height: widget.height.sp,
      fit: BoxFit.contain,
      controller: _controller,
      onLoaded: (composition) {
        _controller
          ..duration = composition.duration
          ..forward()
          ..repeat();
        // Set speed to 2x
        _controller.value = 0;
        _controller.animateTo(
          1.0,
          duration: Duration(
            milliseconds: (composition.duration.inMilliseconds / widget.speed).round(),
          ),
        ).then((_) {
          // Loop the animation
          _controller.repeat(
            period: Duration(
              milliseconds: (composition.duration.inMilliseconds / widget.speed).round(),
            ),
          );
        });
      },
    );
  }
}
