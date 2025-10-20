import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/dialog/basic_dialog.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/card/notification_card.dart';

class Notification extends StatefulWidget {
  const Notification({super.key});

  @override
  State<Notification> createState() => _NotificationState();
}

class _NotificationState extends State<Notification> {
  final List<Map<String, dynamic>> _notificationList = [
    {
      'title': 'Chào mừng bạn đến với Plantheon!',
      'dateTime': '20/10/2025 09:00',
      'isRead': false,
    },
    {
      'title': 'Kết quả quét bệnh',
      'dateTime': '19/10/2025 14:30',
      'isRead': true,
    },
    {
      'title': 'Bài viết mới từ cộng đồng',
      'dateTime': '19/10/2025 10:15',
      'isRead': false,
    },
    {
      'title': 'Nhắc nhở tưới cây',
      'dateTime': '18/10/2025 08:00',
      'isRead': true,
    },
    {
      'title': 'Cập nhật ứng dụng',
      'dateTime': '17/10/2025 16:45',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: 'Thông báo',
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => BasicDialog(
                  title: "Xóa tất cả thông báo",
                  content: "Bạn có chắc chắn muốn xóa tất cả thông báo?",
                  onConfirm: () {
                    setState(() {
                      _notificationList.clear();
                    });
                    Navigator.of(context).pop();
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
            icon: SvgPicture.asset(
              AppVectors.trash,
              width: 24.sp,
              height: 24.sp,
            ),
          ),
        ],
      ),
      body: _notificationList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppVectors.bell,
                    width: 60.sp,
                    height: 60.sp,
                    color: AppColors.text_color_100,
                  ),
                  SizedBox(height: 16.sp),
                  Text(
                    'Không có thông báo nào',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.text_color_200,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: ListView.separated(
                itemCount: _notificationList.length,
                separatorBuilder: (context, index) => Divider(
                  height: 16.sp,
                  color: AppColors.text_color_100,
                  thickness: 1.sp,
                ),
                itemBuilder: (context, index) {
                  final notification = _notificationList[index];
                  return Dismissible(
                    key: ValueKey(notification['dateTime']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20.sp),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        _notificationList.removeAt(index);
                      });
                    },
                    child: GestureDetector(
                      onTap: () {
                        if (!notification['isRead']) {
                          setState(() {
                            notification['isRead'] = true;
                          });
                        }
                      },
                      child: NotificationCard(
                        title: notification['title'],
                        dateTime: notification['dateTime'],
                        isRead: notification['isRead'],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
