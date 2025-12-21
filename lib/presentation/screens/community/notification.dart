import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/dialog/basic_dialog.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/data/datasources/notification_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/auth_repository_impl.dart';
import 'package:se501_plantheon/data/repository/notification_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/notification/clear_notifications.dart';
import 'package:se501_plantheon/domain/usecases/notification/delete_notification.dart';
import 'package:se501_plantheon/domain/usecases/notification/get_notifications.dart';
import 'package:se501_plantheon/domain/usecases/notification/mark_notification_seen.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/notification/notification_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/notification/notification_event.dart';
import 'package:se501_plantheon/presentation/bloc/notification/notification_state.dart';
import 'package:se501_plantheon/presentation/screens/community/post_detail.dart';
import 'package:se501_plantheon/presentation/screens/community/widgets/card/notification_card.dart';

class Notification extends StatefulWidget {
  const Notification({super.key});

  @override
  State<Notification> createState() => _NotificationState();
}

class _NotificationState extends State<Notification> {
  String _formatDateTime(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final day = localDateTime.day.toString().padLeft(2, '0');
    final month = localDateTime.month.toString().padLeft(2, '0');
    final year = localDateTime.year.toString();
    final hour = localDateTime.hour.toString().padLeft(2, '0');
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final remoteDataSource = NotificationRemoteDataSource(
          client: http.Client(),
          tokenStorage:
              (context.read<AuthBloc>().authRepository as AuthRepositoryImpl)
                  .tokenStorage,
        );
        final repository = NotificationRepositoryImpl(
          remoteDataSource: remoteDataSource,
        );

        return NotificationBloc(
          getNotifications: GetNotifications(repository: repository),
          deleteNotification: DeleteNotification(repository: repository),
          clearNotifications: ClearNotificationsUseCase(repository: repository),
          markNotificationSeen: MarkNotificationSeen(repository: repository),
        )..add(FetchNotifications());
      },
      child: Scaffold(
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
                    confirmText: "Xóa",
                    cancelText: "Hủy",
                    onConfirm: () {
                      context.read<NotificationBloc>().add(
                        ClearNotifications(),
                      );
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
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: LoadingIndicator());
            } else if (state is NotificationError) {
              return Center(child: Text(state.message));
            } else if (state is NotificationLoaded) {
              final notifications = state.notifications;

              if (notifications.isEmpty) {
                return Center(
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
                );
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.sp),
                child: ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 16.sp,
                    color: AppColors.text_color_100,
                    thickness: 1.sp,
                  ),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Dismissible(
                      key: ValueKey(notification.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20.sp),
                        child: SvgPicture.asset(
                          AppVectors.trash,
                          width: 24.sp,
                          height: 24.sp,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        bool? shouldDelete = false;
                        await showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return BasicDialog(
                              title: 'Xóa thông báo',
                              content:
                                  'Bạn có chắc chắn muốn xóa thông báo này?',
                              confirmText: 'Xóa',
                              cancelText: 'Hủy',
                              onConfirm: () {
                                shouldDelete = true;
                                Navigator.of(dialogContext).pop();
                              },
                              onCancel: () {
                                shouldDelete = false;
                                Navigator.of(dialogContext).pop();
                              },
                            );
                          },
                        );
                        return shouldDelete ?? false;
                      },
                      onDismissed: (direction) {
                        context.read<NotificationBloc>().add(
                          RemoveNotification(notification.id),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          if (!notification.isRead) {
                            context.read<NotificationBloc>().add(
                              MarkNotificationRead(notification.id),
                            );
                          } else {
                            // Even if already read, we might still want to ensure sync with backend
                            context.read<NotificationBloc>().add(
                              MarkNotificationRead(notification.id),
                            );
                          }

                          if (notification.postId != null &&
                              notification.postId!.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostDetail(postId: notification.postId!),
                              ),
                            );
                          }
                        },
                        child: NotificationCard(
                          title: notification.title,
                          dateTime: _formatDateTime(notification.createdAt),
                          isRead: notification.isRead,
                          content: notification.content,
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
