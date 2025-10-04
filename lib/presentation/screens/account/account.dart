import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/common/widgets/dialog/basic_dialog.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/account/contact.dart';
import 'package:se501_plantheon/presentation/screens/account/edit_info.dart';
import 'package:se501_plantheon/presentation/screens/account/widgets/setting_list_item.dart';
import 'package:se501_plantheon/presentation/screens/account/widgets/setting_title_item.dart';
import 'package:se501_plantheon/presentation/screens/authentication/login.dart';
import 'package:se501_plantheon/presentation/screens/home/scan_history.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(title: "Tài khoản", leading: SizedBox()),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        child: SingleChildScrollView(
          child: Column(
            spacing: 16.sp,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.sp),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.primary_200.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Row(
                    children: [
                      Container(
                        height: 60.sp,
                        width: 60.sp,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary_400,
                              AppColors.primary_600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary_400.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.person,
                            size: 40.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.sp),
                      Expanded(
                        child: Column(
                          spacing: 8.sp,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nguyễn Di Hưng',
                              style: AppTextStyles.s20Bold(
                                color: Colors.grey[800],
                              ).copyWith(letterSpacing: 0.5.sp),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.sp,
                                vertical: 4.sp,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary_50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primary_200,
                                  width: 1.sp,
                                ),
                              ),
                              child: Text(
                                'Thành viên Plantheon',
                                style: AppTextStyles.s12Medium(
                                  color: AppColors.primary_700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.sp),
                        decoration: BoxDecoration(
                          color: AppColors.primary_50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 20.sp,
                          color: AppColors.primary_600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PersonalSetting(),
              HelpingSetting(),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => BasicDialog(
                      title: 'Xác nhận đăng xuất',
                      content: 'Bạn có chắc chắn muốn đăng xuất?',
                      confirmText: 'Đăng xuất',
                      cancelText: 'Huỷ',
                      onConfirm: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => SignInPage(),
                          ),
                        );
                      },
                      onCancel: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFE6F3F1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SettingListItem(
                      leading: SizedBox(),
                      text: "Đăng xuất",
                      action: SvgPicture.asset(
                        AppVectors.logout,
                        width: 20.sp,
                        height: 20.sp,
                        color: AppColors.primary_700,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100.sp),
            ],
          ),
        ),
      ),
    );
  }
}

class PersonalSetting extends StatefulWidget {
  const PersonalSetting({super.key});

  @override
  _PersonalSettingState createState() => _PersonalSettingState();
}

class _PersonalSettingState extends State<PersonalSetting> {
  bool isNotificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    String _selectedLanguage = 'vi';

    void _showLanguageDialog() {
      showDialog(
        context: context,
        builder: (context) {
          String tempLanguage = _selectedLanguage;
          return StatefulBuilder(
            builder: (context, setState) {
              return BasicDialog(
                width: 100.sp,
                title: 'Chọn ngôn ngữ',
                content: '',
                confirmText: 'Xác nhận',
                cancelText: 'Huỷ',
                onConfirm: () {
                  setState(() {
                    _selectedLanguage = tempLanguage;
                  });
                },
                onCancel: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: SvgPicture.asset(
                        AppVectors.vi,
                        width: 40.sp,
                        height: 40.sp,
                      ),
                      value: 'vi',
                      groupValue: tempLanguage,
                      activeColor: AppColors.primary_main,

                      onChanged: (value) {
                        setState(() {
                          tempLanguage = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: SvgPicture.asset(
                        AppVectors.en,
                        width: 40.sp,
                        height: 40.sp,
                      ),
                      value: 'en',
                      activeColor: AppColors.primary_main,
                      groupValue: tempLanguage,
                      onChanged: (value) {
                        setState(() {
                          tempLanguage = value!;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE6F3F1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingTitleItem(text: "Cá nhân"),
            Divider(height: 1, color: AppColors.white),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => EditInfo(),
                  ),
                );
              },
              child: SettingListItem(
                leading: SvgPicture.asset(
                  AppVectors.userEdit,
                  width: 20.sp,
                  height: 20.sp,
                  color: AppColors.primary_700,
                ),
                text: "Chỉnh sửa hồ sơ",
                action: Icon(Icons.keyboard_arrow_right_rounded, size: 20.sp),
              ),
            ),
            Divider(height: 1, color: AppColors.white),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ScanHistory(),
                  ),
                );
              },
              child: SettingListItem(
                leading: SvgPicture.asset(
                  AppVectors.history,
                  width: 19.sp,
                  height: 19.sp,
                  color: AppColors.primary_700,
                ),
                text: "Lịch sử quét bệnh",
                action: Icon(Icons.keyboard_arrow_right_rounded, size: 20.sp),
              ),
            ),
            Divider(height: 1, color: AppColors.white),
            SettingListItem(
              isHavePadding: false,
              leading: SvgPicture.asset(
                AppVectors.bell,
                width: 20.sp,
                height: 20.sp,
                color: AppColors.primary_700,
              ),
              text: "Thông báo",
              action: Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      isNotificationsEnabled = value;
                    });
                  },
                  thumbColor: MaterialStateProperty.all(AppColors.white),
                  trackColor: MaterialStateProperty.resolveWith<Color>((
                    states,
                  ) {
                    if (states.contains(MaterialState.selected)) {
                      return AppColors.primary_main;
                    }
                    return AppColors.text_color_100;
                  }),
                ),
              ),
            ),
            Divider(height: 1, color: AppColors.white),
            GestureDetector(
              onTap: _showLanguageDialog,
              child: SettingListItem(
                leading: SvgPicture.asset(
                  AppVectors.global,
                  width: 20.sp,
                  height: 20.sp,
                  color: AppColors.primary_700,
                ),
                text: "Ngôn ngữ",
                action: Icon(Icons.keyboard_arrow_right_rounded, size: 20.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpingSetting extends StatelessWidget {
  const HelpingSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE6F3F1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingTitleItem(text: "Hỗ trợ"),
            Divider(height: 1, color: AppColors.white),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Contact(),
                  ),
                );
              },
              child: SettingListItem(
                leading: SvgPicture.asset(
                  AppVectors.phone,
                  width: 20.sp,
                  height: 20.sp,
                  color: AppColors.primary_700,
                ),
                text: "Liên hệ",
                action: Icon(Icons.keyboard_arrow_right_rounded, size: 20.sp),
              ),
            ),
            Divider(height: 1, color: AppColors.white),
            SettingListItem(
              leading: SvgPicture.asset(
                AppVectors.report,
                width: 20.sp,
                height: 20.sp,
                color: AppColors.primary_700,
              ),
              text: "Báo cáo",
              action: Icon(Icons.keyboard_arrow_right_rounded, size: 20.sp),
            ),
          ],
        ),
      ),
    );
  }
}
