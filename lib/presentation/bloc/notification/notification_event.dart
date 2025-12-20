abstract class NotificationEvent {}

class FetchNotifications extends NotificationEvent {}

class MarkNotificationRead extends NotificationEvent {
  final String notificationId;

  MarkNotificationRead(this.notificationId);
}

class RemoveNotification extends NotificationEvent {
  final String notificationId;

  RemoveNotification(this.notificationId);
}

class ClearNotifications extends NotificationEvent {}
