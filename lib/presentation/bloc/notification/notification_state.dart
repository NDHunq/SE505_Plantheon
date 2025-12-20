import 'package:se501_plantheon/domain/entities/notification_entity.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;

  NotificationLoaded({required this.notifications});
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError({required this.message});
}