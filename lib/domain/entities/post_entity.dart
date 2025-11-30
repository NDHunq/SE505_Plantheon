import 'package:se501_plantheon/domain/entities/comment_entity.dart';

class PostEntity {
  final String id;
  final String userId;
  final String fullName;
  final String avatar;
  final String content;
  final List<String>? imageLink;
  final List<String> tags;
  final int likeNumber;
  final bool liked;
  final int commentNumber;
  final List<CommentEntity>? commentList;
  final int shareNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostEntity({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.avatar,
    required this.content,
    this.imageLink,
    required this.tags,
    required this.likeNumber,
    required this.liked,
    required this.commentNumber,
    this.commentList,
    required this.shareNumber,
    required this.createdAt,
    required this.updatedAt,
  });
}
