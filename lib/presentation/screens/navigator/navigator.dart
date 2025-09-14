import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/presentation/screens/account/account.dart';
import 'package:se501_plantheon/presentation/screens/community/community.dart';
import 'package:se501_plantheon/presentation/screens/diary/diary.dart';
import 'package:se501_plantheon/presentation/screens/home/home.dart';
import 'package:se501_plantheon/core/services/navigation_service.dart';

class Navigation extends StatefulWidget {
  final int? tab;
  final int? userId;
  const Navigation({super.key, this.tab, this.userId});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.tab != null) {
      currentPageIndex = widget.tab!;
    }

    // Set up navigation service callback
    NavigationService.instance.setTabChangeCallback((int tabIndex) {
      if (mounted) {
        setState(() {
          currentPageIndex = tabIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    NavigationService.instance.removeCallback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _navigationBar(),
      body: [
        const Home(),
        const Community(),
        const Diary(),
        const Account(),
      ][currentPageIndex],
    );
  }

  Widget _navigationBar() {
    return NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
        });
      },
      height: 56,
      indicatorColor: Colors.transparent,
      // indicatorShape: const Border(
      //   top: BorderSide(
      //     color: AppColors.xanh_main,
      //     width: 4,
      //   ),
      // ),
      destinations: [
        NavigationDestination(
          selectedIcon: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SvgPicture.asset(
              AppVectors.homeSolid,
              height: 23,
              width: 23,
            ),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SvgPicture.asset(
              AppVectors.homeStroke,
              height: 23,
              width: 23,
            ),
          ),
          label: '',
        ),
        NavigationDestination(
          selectedIcon: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SvgPicture.asset(
              AppVectors.diarySolid,
              height: 23,
              width: 23,
            ),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SvgPicture.asset(
              AppVectors.diaryStroke,
              height: 23,
              width: 23,
            ),
          ),
          label: '',
        ),
        NavigationDestination(
          selectedIcon: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SvgPicture.asset(
              AppVectors.communitySolid,
              height: 23,
              width: 23,
            ),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SvgPicture.asset(
              AppVectors.communityStroke,
              height: 23,
              width: 23,
            ),
          ),
          label: '',
        ),
        NavigationDestination(
          selectedIcon: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SvgPicture.asset(
              AppVectors.accountSolid,
              height: 23,
              width: 23,
            ),
          ),
          icon: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SvgPicture.asset(
              AppVectors.accountStroke,
              height: 23,
              width: 23,
            ),
          ),
          label: '',
        ),
      ],
      selectedIndex: currentPageIndex,
    );
  }
}
