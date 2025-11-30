import 'package:se501_plantheon/domain/entities/comment_entity.dart';

class CommentModel {
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

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.fullName,
    required this.avatar,
    required this.content,
    required this.likeNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.isMe,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String? ?? '',
      postId: json['post_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      content: json['content'] as String? ?? '',
      likeNumber: json['like_number'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isMe: json['is_me'] as bool? ?? false,
    );
  }

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      postId: postId,
      userId: userId,
      fullName: fullName,
      avatar: avatar,
      content: content,
      likeNumber: likeNumber,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isMe: isMe,
    );
  }
}
