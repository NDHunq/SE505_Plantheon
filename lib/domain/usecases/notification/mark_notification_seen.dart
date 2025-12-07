import 'package:se501_plantheon/domain/repository/notification_repository.dart';

class MarkNotificationSeen {
  final NotificationRepository repository;

  MarkNotificationSeen({required this.repository});

  Future<void> call(String id) {
    return repository.markNotificationSeen(id);
  }
}
