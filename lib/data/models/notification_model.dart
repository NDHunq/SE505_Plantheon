import 'package:se501_plantheon/domain/entities/notification_entity.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final bool isRead;
  final String? postId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.isRead,
    this.postId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      postId: json['post_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      userId: userId,
      title: title,
      content: content,
      isRead: isRead,
      postId: postId,
      createdAt: createdAt,
    );
  }
}

class NotificationResponseModel {
  final List<NotificationModel> notifications;
  final int total;

  NotificationResponseModel({required this.notifications, required this.total});

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final notificationsList = data['notifications'] as List<dynamic>? ?? [];

    return NotificationResponseModel(
      notifications: notificationsList
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
      total: data['total'] as int? ?? 0,
    );
  }
}
