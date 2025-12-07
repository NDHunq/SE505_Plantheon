import 'package:se501_plantheon/domain/repository/notification_repository.dart';

class ClearNotificationsUseCase {
  final NotificationRepository repository;

  ClearNotificationsUseCase({required this.repository});

  Future<void> call() {
    return repository.clearNotifications();
  }
}
