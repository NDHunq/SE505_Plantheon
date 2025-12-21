import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/account/widgets/setting_list_item.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatelessWidget {
  const Contact({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> _launchPhone(String phone) async {
      final uri = Uri(scheme: 'tel', path: phone);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở ứng dụng gọi')),
        );
      }
    }

    Future<void> _launchEmail(String email) async {
      final uri = Uri(scheme: 'mailto', path: email);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở ứng dụng email')),
        );
      }
    }

    Future<void> _launchMapUrl(String url) async {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở ứng dụng bản đồ')),
        );
      }
    }

    return Scaffold(
      appBar: BasicAppbar(title: "Liên hệ"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => _launchPhone('0345664024'),
                child: SettingListItem(
                  leading: SvgPicture.asset(
                    AppVectors.phone,
                    width: 19.sp,
                    height: 19.sp,
                    color: AppColors.primary_700,
                  ),
                  text: "Số điện thoại",
                  action: Row(
                    spacing: 4.sp,
                    children: [
                      Text(
                        "0345664024",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.text_color_200,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right_rounded,
                        size: 20.sp,
                        color: AppColors.text_color_200,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1.sp, color: AppColors.text_color_100),
              InkWell(
                onTap: () => _launchEmail('dhunqkk@gmail.com'),
                child: SettingListItem(
                  leading: SvgPicture.asset(
                    AppVectors.global,
                    width: 19.sp,
                    height: 19.sp,
                    color: AppColors.primary_700,
                  ),
                  text: "Email",
                  action: Row(
                    spacing: 4.sp,
                    children: [
                      Text(
                        "dhunqkk@gmail.com",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.text_color_200,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right_rounded,
                        size: 20.sp,
                        color: AppColors.text_color_200,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1.sp, color: AppColors.text_color_100),
              InkWell(
                onTap: () =>
                    _launchMapUrl('https://maps.app.goo.gl/hgf8tFn8GrtY9HaM8'),
                child: SettingListItem(
                  leading: SvgPicture.asset(
                    AppVectors.location,
                    width: 19.sp,
                    height: 19.sp,
                    color: AppColors.primary_700,
                  ),
                  text: "Địa chỉ",
                  action: Row(
                    spacing: 4.sp,
                    children: [
                      Text(
                        "Khu phố 34, Phường Linh Xuân,\n Thành phố Hồ Chí Minh",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.text_color_200,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right_rounded,
                        size: 20.sp,
                        color: AppColors.text_color_200,
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1.sp, color: AppColors.text_color_100),
              InkWell(
                onTap: () => _launchMapUrl(
                  'https://www.facebook.com/ndhunq7924?locale=vi_VN',
                ),
                child: SettingListItem(
                  leading: SvgPicture.asset(
                    AppVectors.global,
                    width: 19.sp,
                    height: 19.sp,
                    color: AppColors.primary_700,
                  ),
                  text: "Facebook",
                  action: Icon(
                    Icons.keyboard_arrow_right_rounded,
                    size: 20.sp,
                    color: AppColors.text_color_200,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
