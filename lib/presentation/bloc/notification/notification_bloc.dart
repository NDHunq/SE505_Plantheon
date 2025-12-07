import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se501_plantheon/domain/usecases/notification/clear_notifications.dart';
import 'package:se501_plantheon/domain/usecases/notification/delete_notification.dart';
import 'package:se501_plantheon/domain/usecases/notification/get_notifications.dart';
import 'package:se501_plantheon/domain/usecases/notification/mark_notification_seen.dart';
import 'package:se501_plantheon/presentation/bloc/notification/notification_event.dart';
import 'package:se501_plantheon/presentation/bloc/notification/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotifications getNotificationsUseCase;
  final DeleteNotification deleteNotificationUseCase;
  final ClearNotificationsUseCase clearNotificationsUseCase;
  final MarkNotificationSeen markNotificationSeenUseCase;

  NotificationBloc({
    required GetNotifications getNotifications,
    required DeleteNotification deleteNotification,
    required ClearNotificationsUseCase clearNotifications,
    required MarkNotificationSeen markNotificationSeen,
  }) : getNotificationsUseCase = getNotifications,
       deleteNotificationUseCase = deleteNotification,
       clearNotificationsUseCase = clearNotifications,
       markNotificationSeenUseCase = markNotificationSeen,
       super(NotificationInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<MarkNotificationRead>(_onMarkNotificationRead);
    on<RemoveNotification>(_onRemoveNotification);
    on<ClearNotifications>(_onClearNotifications);
  }

  Future<void> _onFetchNotifications(
    FetchNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await getNotificationsUseCase();
      emit(NotificationLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onMarkNotificationRead(
    MarkNotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final updated = List.of(currentState.notifications);

      final index = updated.indexWhere(
        (notification) => notification.id == event.notificationId,
      );
      if (index != -1) {
        // Optimistic update
        final original = updated[index];
        updated[index] = updated[index].copyWith(isRead: true);
        emit(NotificationLoaded(notifications: updated));

        try {
          await markNotificationSeenUseCase(event.notificationId);
        } catch (e) {
          // Revert and show error
          updated[index] = original;
          emit(NotificationLoaded(notifications: updated));
          emit(
            NotificationError(
              message: 'Đánh dấu đã đọc thất bại: ${e.toString()}',
            ),
          );
        }
      }
    }
  }

  Future<void> _onRemoveNotification(
    RemoveNotification event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final updated = currentState.notifications
          .where((notification) => notification.id != event.notificationId)
          .toList();

      // Optimistic update
      emit(NotificationLoaded(notifications: updated));

      try {
        await deleteNotificationUseCase(event.notificationId);
      } catch (e) {
        // Revert and show error
        emit(
          NotificationError(message: 'Xóa thông báo thất bại: ${e.toString()}'),
        );
        emit(currentState);
      }
    }
  }

  Future<void> _onClearNotifications(
    ClearNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      await clearNotificationsUseCase();
      emit(NotificationLoaded(notifications: const []));
    } catch (e) {
      emit(NotificationError(message: 'Xóa tất cả thông báo thất bại: $e'));
    }
  }
}
