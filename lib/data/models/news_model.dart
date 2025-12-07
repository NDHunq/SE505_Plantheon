import 'package:se501_plantheon/domain/entities/news_entity.dart';

DateTime? _parseDate(String? value) {
  if (value == null) return null;
  try {
    return DateTime.tryParse(value);
  } catch (_) {
    return null;
  }
}

class NewsModel {
  final String id;
  final String title;
  final String? description;
  final String? content;
  final String? blogTagId;
  final String? blogTagName;
  final String coverImageUrl;
  final String status;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final String fullName;
  final String avatar;

  NewsModel({
    required this.id,
    required this.title,
    this.description,
    this.content,
    this.blogTagId,
    this.blogTagName,
    required this.coverImageUrl,
    required this.status,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.fullName,
    required this.avatar,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    final createdAt = _parseDate(json['created_at'] as String?);
    final updatedAt = _parseDate(json['updated_at'] as String?);

    return NewsModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      content: json['content'] as String?,
      blogTagId: json['blog_tag_id'] as String?,
      blogTagName: json['blog_tag_name'] as String?,
      coverImageUrl: json['cover_image_url'] as String? ?? '',
      status: json['status'] as String? ?? '',
      publishedAt: _parseDate(json['published_at'] as String?),
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      userId: json['user_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
    );
  }

  NewsEntity toEntity() {
    return NewsEntity(
      id: id,
      title: title,
      description: description,
      content: content,
      blogTagId: blogTagId,
      blogTagName: blogTagName,
      coverImageUrl: coverImageUrl,
      status: status,
      publishedAt: publishedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
      fullName: fullName,
      avatar: avatar,
    );
  }
}

class NewsResponseModel {
  final List<NewsModel> news;
  final int total;

  NewsResponseModel({required this.news, required this.total});

  factory NewsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final newsJson = data['news'] as List<dynamic>? ?? [];

    return NewsResponseModel(
      news: newsJson
          .map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int? ?? newsJson.length,
    );
  }
}
