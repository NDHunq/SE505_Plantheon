import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/dialog/basic_dialog.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/account/contact.dart';
import 'package:se501_plantheon/presentation/screens/authentication/login.dart';
import 'package:se501_plantheon/presentation/screens/home/scan_history.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(title: "Tài khoản", leading: SizedBox()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          spacing: 16,
          children: [
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
                      width: 24,
                      height: 24,
                      color: AppColors.primary_700,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
                width: 100,
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
                        width: 40,
                        height: 40,
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
                        width: 40,
                        height: 40,
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
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingTitleItem(text: "Cá nhân"),
            Divider(height: 1, color: AppColors.white),
            SettingListItem(
              leading: SvgPicture.asset(
                AppVectors.userEdit,
                width: 24,
                height: 24,
                color: AppColors.primary_700,
              ),
              text: "Chỉnh sửa hồ sơ",
              action: Icon(Icons.keyboard_arrow_right_rounded),
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
                  width: 24,
                  height: 24,
                  color: AppColors.primary_700,
                ),
                text: "Lịch sử quét bệnh",
                action: Icon(Icons.keyboard_arrow_right_rounded),
              ),
            ),
            Divider(height: 1, color: AppColors.white),
            SettingListItem(
              leading: SvgPicture.asset(
                AppVectors.bell,
                width: 24,
                height: 24,
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
                  width: 24,
                  height: 24,
                  color: AppColors.primary_700,
                ),
                text: "Ngôn ngữ",
                action: Icon(Icons.keyboard_arrow_right_rounded),
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
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                  width: 24,
                  height: 24,
                  color: AppColors.primary_700,
                ),
                text: "Liên hệ",
                action: Icon(Icons.keyboard_arrow_right_rounded),
              ),
            ),
            Divider(height: 1, color: AppColors.white),
            SettingListItem(
              leading: SvgPicture.asset(
                AppVectors.report,
                width: 24,
                height: 24,
                color: AppColors.primary_700,
              ),
              text: "Báo cáo",
              action: Icon(Icons.keyboard_arrow_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingTitleItem extends StatelessWidget {
  final String text;
  const SettingTitleItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class SettingListItem extends StatelessWidget {
  final Widget leading;
  final String text;
  final Widget action;
  const SettingListItem({
    super.key,
    required this.leading,
    required this.text,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        children: [
          leading,
          SizedBox(width: 16),
          Text(text, style: AppTextStyles.s14Medium()),
          Spacer(),
          action,
        ],
      ),
    );
  }
}
