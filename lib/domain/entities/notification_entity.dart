class NotificationEntity {
  final String id;
  final String userId;
  final String title;
  final String content;
  final bool isRead;
  final String? postId;
  final DateTime createdAt;

  NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.isRead,
    this.postId,
    required this.createdAt,
  });

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      userId: userId,
      title: title,
      content: content,
      isRead: isRead ?? this.isRead,
      postId: postId,
      createdAt: createdAt,
    );
  }
}
