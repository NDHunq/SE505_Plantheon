import 'package:se501_plantheon/domain/repository/notification_repository.dart';

class DeleteNotification {
  final NotificationRepository repository;

  DeleteNotification({required this.repository});

  Future<void> call(String id) {
    return repository.deleteNotification(id);
  }
}
