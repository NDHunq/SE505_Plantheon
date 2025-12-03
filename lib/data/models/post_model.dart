import 'package:se501_plantheon/data/models/comment_model.dart';
import 'package:se501_plantheon/domain/entities/post_entity.dart';

class PostModel {
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
  final List<CommentModel>? commentList;
  final int shareNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
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

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageLink: (json['image_link'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      diseaseLink: json['disease_link'] as String?,
      diseaseName: json['disease_name'] as String?,
      diseaseDescription: json['disease_description'] as String?,
      diseaseSolution: json['disease_solution'] as String?,
      diseaseImageLink: json['disease_image_link'] as String?,
      scanHistoryId: json['scan_history_id'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      likeNumber: json['like_number'] as int? ?? 0,
      liked: json['liked'] as bool? ?? false,
      commentNumber: json['comment_number'] as int? ?? 0,
      commentList: (json['comment_list'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      shareNumber: json['share_number'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  PostEntity toEntity() {
    return PostEntity(
      id: id,
      userId: userId,
      fullName: fullName,
      avatar: avatar,
      content: content,
      imageLink: imageLink,
      diseaseLink: diseaseLink,
      diseaseName: diseaseName,
      diseaseDescription: diseaseDescription,
      diseaseSolution: diseaseSolution,
      diseaseImageLink: diseaseImageLink,
      scanHistoryId: scanHistoryId,
      tags: tags,
      likeNumber: likeNumber,
      liked: liked,
      commentNumber: commentNumber,
      commentList: commentList?.map((e) => e.toEntity()).toList(),
      shareNumber: shareNumber,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class PostResponseModel {
  final List<PostModel> posts;
  final int total;

  PostResponseModel({required this.posts, required this.total});

  factory PostResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final postsList = data['posts'] as List<dynamic>? ?? [];
    return PostResponseModel(
      posts: postsList.map((e) => PostModel.fromJson(e)).toList(),
      total: data['total'] as int? ?? 0,
    );
  }
}
