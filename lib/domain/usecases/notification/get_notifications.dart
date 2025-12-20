import 'package:se501_plantheon/domain/entities/notification_entity.dart';
import 'package:se501_plantheon/domain/repository/notification_repository.dart';

class GetNotifications {
  final NotificationRepository repository;

  GetNotifications({required this.repository});

  Future<List<NotificationEntity>> call() {
    return repository.getNotifications();
  }
}
