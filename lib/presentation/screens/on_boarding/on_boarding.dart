import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/core/configs/assets/app_images.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/authentication/login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<Map<String, String>> onboardingData = [
    {
      "title": "Chẩn đoán bệnh thần tốc",
      "text":
          "Chỉ cần một lần quét, AI sẽ giúp bạn phát hiện chính xác sâu bệnh hại để kịp thời xử lý.",
      "image": AppImages.onBoarding1,
    },
    {
      "title": "Giải pháp canh tác tối ưu",
      "text":
          "Cung cấp phác đồ điều trị hiệu quả và các mẹo chăm sóc chuẩn kỹ thuật cho mùa màng bội thu.",
      "image": AppImages.onBoarding2,
    },
    {
      "title": "Kết nối cộng đồng nhà nông",
      "text":
          "Tham gia mạng xã hội nông nghiệp, nơi giao lưu và chia sẻ bí quyết canh tác cùng những người bạn đồng hành.",
      "image": AppImages.onBoarding3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            SizedBox(
              height: 430.sp,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  Color tabColor;
                  if (index == 0) {
                    tabColor = AppColors.primary_600;
                  } else if (index == 1) {
                    tabColor = Color.fromARGB(255, 241, 127, 33);
                  } else {
                    tabColor = Color(0xFF1074BC);
                    ;
                  }
                  return OnboardingContent(
                    title: onboardingData[index]['title']!,
                    text: onboardingData[index]['text']!,
                    image: onboardingData[index]['image']!,
                    color: tabColor,
                  );
                },
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.sp,
                      vertical: 16.sp,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            onboardingData.length,
                            (index) => buildDot(
                              index: index,
                              color: AppColors.primary_600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => SignInPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Bỏ qua",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50.sp,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage == 0
                            ? AppColors.primary_600
                            : _currentPage == 1
                            ? Color.fromARGB(255, 241, 127, 33)
                            : Color(0xFF1074BC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.sp),
                        ),
                      ),
                      onPressed: () {
                        if (_currentPage == onboardingData.length - 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => SignInPage(),
                            ),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == onboardingData.length - 1
                            ? "Bắt đầu ngay"
                            : "Tiếp tục",
                        style: TextStyle(fontSize: 18.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({required int index, required Color color}) {
    Color dotColor;
    if (index == 0) {
      dotColor = AppColors.primary_600;
    } else if (index == 1) {
      dotColor = Color.fromARGB(255, 241, 127, 33);
    } else {
      dotColor = Color(0xFF1074BC);
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 5.sp),
      height: 6.sp,
      width: _currentPage == index ? 20.sp : 6.sp,
      decoration: BoxDecoration(
        color: _currentPage == index ? dotColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(3.sp),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String title, text, image;
  final Color color;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.text,
    required this.image,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 16.sp),
        Image.asset(image, height: 300.sp, width: 300.sp, fit: BoxFit.contain),
        SizedBox(height: 16.sp),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.sp),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, color: color),
          ),
        ),
      ],
    );
  }
}
