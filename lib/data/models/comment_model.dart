import 'package:se501_plantheon/domain/entities/comment_entity.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String? parentId;
  final String fullName;
  final String avatar;
  final String content;
  final int likeNumber;
  final bool isLike;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isMe;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.fullName,
    required this.avatar,
    required this.content,
    required this.likeNumber,
    required this.isLike,
    required this.createdAt,
    required this.updatedAt,
    required this.isMe,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String? ?? '',
      postId: json['post_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      parentId: json['parent_id'] as String?,
      fullName: json['full_name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      content: json['content'] as String? ?? '',
      likeNumber: json['like_number'] as int? ?? 0,
      isLike: json['is_like'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      isMe: json['is_me'] as bool? ?? false,
    );
  }

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      postId: postId,
      userId: userId,
      parentId: parentId,
      fullName: fullName,
      avatar: avatar,
      content: content,
      likeNumber: likeNumber,
      isLike: isLike,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isMe: isMe,
    );
  }
}
