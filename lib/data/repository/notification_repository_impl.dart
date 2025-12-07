import 'package:se501_plantheon/data/datasources/notification_remote_datasource.dart';
import 'package:se501_plantheon/domain/entities/notification_entity.dart';
import 'package:se501_plantheon/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final models = await remoteDataSource.getNotifications();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> deleteNotification(String id) async {
    await remoteDataSource.deleteNotification(id);
  }

  @override
  Future<void> clearNotifications() async {
    await remoteDataSource.clearNotifications();
  }

  @override
  Future<void> markNotificationSeen(String id) async {
    await remoteDataSource.markNotificationSeen(id);
  }
}
