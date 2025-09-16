import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/account/account.dart';
import 'package:se501_plantheon/presentation/screens/community/community.dart';
import 'package:se501_plantheon/presentation/screens/diary/diary.dart';
import 'package:se501_plantheon/presentation/screens/home/home.dart';
import 'package:se501_plantheon/presentation/screens/scan/scan.dart';

class CustomNavigator extends StatefulWidget {
  const CustomNavigator({Key? key}) : super(key: key);

  @override
  State<CustomNavigator> createState() => _CustomNavigatorState();
}

class _CustomNavigatorState extends State<CustomNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [Home(), Diary(), Scan(), Community(), Account()];

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
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary_300, width: 5),
          borderRadius: BorderRadius.circular(50),
        ),

        child: FloatingActionButton(
          onPressed: () => _onItemTapped(2),
          backgroundColor: AppColors.primary_main,
          elevation: 0,
          shape: CircleBorder(),
          child: SvgPicture.asset(
            AppVectors.scan,
            height: 30,
            width: 30,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                MaterialButton(
                  minWidth: 40,
                  onPressed: () => _onItemTapped(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        _selectedIndex == 0
                            ? AppVectors.homeSolid
                            : AppVectors.homeStroke,
                        height: 25,
                        width: 25,
                      ),
                      Text(
                        'Trang chủ',
                        style: TextStyle(
                          color: _selectedIndex == 0
                              ? Colors.green
                              : Colors.grey,
                          fontSize: 10,
                        ), // Removed ANSI color code
                      ),
                    ],
                  ),
                ),
                MaterialButton(
                  minWidth: 40,
                  onPressed: () => _onItemTapped(1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        _selectedIndex == 1
                            ? AppVectors.diarySolid
                            : AppVectors.diaryStroke,
                        height: 25,
                        width: 25,
                      ),
                      Text(
                        'Nhật ký',
                        style: TextStyle(
                          color: _selectedIndex == 1
                              ? Colors.green
                              : Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                MaterialButton(
                  minWidth: 40,
                  onPressed: () => _onItemTapped(3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        _selectedIndex == 3
                            ? AppVectors.communitySolid
                            : AppVectors.communityStroke,
                        height: 25,
                        width: 25,
                      ),
                      Text(
                        'Cộng đồng',
                        style: TextStyle(
                          color: _selectedIndex == 3
                              ? Colors.green
                              : Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                MaterialButton(
                  minWidth: 40,
                  onPressed: () => _onItemTapped(4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        _selectedIndex == 4
                            ? AppVectors.accountSolid
                            : AppVectors.accountStroke,
                        height: 25,
                        width: 25,
                      ),
                      Text(
                        'Tài khoản',
                        style: TextStyle(
                          color: _selectedIndex == 4
                              ? Colors.green
                              : Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
