import 'package:se501_plantheon/domain/entities/comment_entity.dart';

class PostEntity {
  final String id;
  final String userId;
  final String fullName;
  final String avatar;
  final String content;
  final List<String>? imageLink;
  final String? diseaseLink;
  final String? diseaseName;
  final String? diseaseDescription;
  final String? diseaseSolution;
  final String? diseaseImageLink;
  final String? scanHistoryId;
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
    this.diseaseLink,
    this.diseaseName,
    this.diseaseDescription,
    this.diseaseSolution,
    this.diseaseImageLink,
    this.scanHistoryId,
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
