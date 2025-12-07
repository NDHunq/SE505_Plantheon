import 'package:se501_plantheon/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> deleteNotification(String id);
  Future<void> clearNotifications();
  Future<void> markNotificationSeen(String id);
}
