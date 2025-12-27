import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/fast_lottie_loading.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/account/account.dart';
import 'package:se501_plantheon/presentation/screens/community/community.dart';
import 'package:se501_plantheon/presentation/screens/diary/diary.dart';
import 'package:se501_plantheon/presentation/screens/home/home.dart';
import 'package:se501_plantheon/presentation/screens/scan/scan.dart';

class CustomNavigator extends StatefulWidget {
  const CustomNavigator({super.key});

  @override
  State<CustomNavigator> createState() => _CustomNavigatorState();
}

class _CustomNavigatorState extends State<CustomNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [Home(), Diary(), Community(), Account()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      floatingActionButton: Container(
        height: 70.sp,
        width: 70.sp,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary_300, width: 5.sp),
          borderRadius: BorderRadius.circular(50.sp),
        ),

        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const Scan()));
          },
          backgroundColor: AppColors.primary_main,
          elevation: 0,
          shape: CircleBorder(),
          child: FastLottieLoading(
            assetPath: 'assets/animations/Scan.json',
            width: 50.sp,
            height: 50.sp,
            speed: 1.0,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[100],
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double horizontalPadding = 0.sp;
            final double availableWidth =
                constraints.maxWidth - (horizontalPadding * 2);
            final double sectionWidth = availableWidth / 5;

            Widget buildNavItem(
              int index,
              String iconSolid,
              String iconStroke,
              String label,
            ) {
              return SizedBox(
                width: sectionWidth,
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(20.sp)),
                  onTap: () => _onItemTapped(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        _selectedIndex == index ? iconSolid : iconStroke,
                        height: 25.sp,
                        width: 25.sp,
                      ),
                      Text(
                        label,
                        style: TextStyle(
                          color: _selectedIndex == index
                              ? AppColors.primary_main
                              : Colors.grey,
                          fontSize: 8.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  buildNavItem(
                    0,
                    AppVectors.homeSolid,
                    AppVectors.homeStroke,
                    'Trang chủ',
                  ),
                  buildNavItem(
                    1,
                    AppVectors.diarySolid,
                    AppVectors.diaryStroke,
                    'Nhật ký',
                  ),
                  SizedBox(width: sectionWidth), // Space for FAB
                  buildNavItem(
                    2,
                    AppVectors.communitySolid,
                    AppVectors.communityStroke,
                    'Cộng đồng',
                  ),
                  buildNavItem(
                    3,
                    AppVectors.accountSolid,
                    AppVectors.accountStroke,
                    'Tài khoản',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
