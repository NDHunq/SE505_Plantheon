class CommentEntity {
  final String id;
  final String postId;
  final String userId;
  final String fullName;
  final String avatar;
  final String content;
  final int likeNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isMe;

  CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.fullName,
    required this.avatar,
    required this.content,
    required this.likeNumber,
    required this.createdAt,
    required this.updatedAt,
    this.isMe = false,
  });
}
