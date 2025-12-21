import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/services.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/presentation/screens/diary/diary.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

/// Full-screen loading screen với hiệu ứng đẹp và xử lý system UI overlays
class FullScreenLoadingScreen extends StatefulWidget {
  const FullScreenLoadingScreen({super.key});

  @override
  State<FullScreenLoadingScreen> createState() =>
      _FullScreenLoadingScreenState();
}

class _FullScreenLoadingScreenState extends State<FullScreenLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _loadingController;
  late AnimationController _pulseController;
  late Animation<double> _logoAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Hide system UI overlays for true full-screen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Loading animation controller
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animation (fade in + scale + bounce)
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Loading animation (rotation)
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.linear),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _logoController.forward();
    _loadingController.repeat();
    _pulseController.repeat(reverse: true);

    // Navigate to main screen after delay
    _navigateToMain();
  }

  @override
  void dispose() {
    // Restore system UI overlays
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _logoController.dispose();
    _loadingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _navigateToMain() async {
    // Simulate app loading time
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Diary(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary_300,
              AppColors.primary_600,
              AppColors.primary_700,
              AppColors.primary_900,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(painter: BackgroundPatternPainter()),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon Animation with pulse effect
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoAnimation,
                      _pulseAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoAnimation.value * _pulseAnimation.value,
                        child: Opacity(
                          opacity: _logoAnimation.value,
                          child: Container(
                            width: 140.sp,
                            height: 140.sp,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(35.sp),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 30.sp,
                                  offset: Offset(0, 15),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 20.sp,
                                  offset: Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.eco,
                              size: 70.sp,
                              color: AppColors.primary_600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 50.sp),

                  // App Name with typing effect
                  AnimatedBuilder(
                    animation: _logoAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              'Plantheon',
                              style: TextStyle(
                                fontSize: 36.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: Offset(2, 2),
                                    blurRadius: 4.sp,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12.sp),
                            Text(
                              'Nhật ký nông nghiệp thông minh',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 80.sp),

                  // Enhanced Loading Indicator
                  AnimatedBuilder(
                    animation: _loadingAnimation,
                    builder: (context, child) {
                      return Column(
                        children: [
                          // Rotating loading ring
                          Transform.rotate(
                            angle: _loadingAnimation.value * 2 * 3.14159,
                            child: Container(
                              width: 60.sp,
                              height: 60.sp,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 4.sp,
                                ),
                              ),
                              child: LoadingIndicator(),
                            ),
                          ),

                          SizedBox(height: 30.sp),

                          // Loading dots animation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return AnimatedBuilder(
                                animation: _loadingAnimation,
                                builder: (context, child) {
                                  final delay = index * 0.2;
                                  final animationValue =
                                      (_loadingAnimation.value - delay).clamp(
                                        0.0,
                                        1.0,
                                      );
                                  final opacity = (animationValue * 2 - 1)
                                      .abs();

                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 4.sp,
                                    ),
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Container(
                                        width: 8.sp,
                                        height: 8.sp,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 30.sp),

                  // Loading Text with fade effect
                  AnimatedBuilder(
                    animation: _logoAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoAnimation.value,
                        child: Text(
                          'Đang khởi tạo ứng dụng...',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw subtle circles pattern
    for (int i = 0; i < 20; i++) {
      final x = (i * 100.0) % size.width;
      final y = (i * 80.0) % size.height;
      final radius = 20.0 + (i % 3) * 10.0;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
