import 'package:se501_plantheon/domain/entities/news_tag_entity.dart';

DateTime? _parseDate(String? value) {
  if (value == null) return null;
  try {
    return DateTime.tryParse(value);
  } catch (_) {
    return null;
  }
}

class NewsTagModel {
  final String id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NewsTagModel({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory NewsTagModel.fromJson(Map<String, dynamic> json) {
    return NewsTagModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdAt: _parseDate(json['created_at'] as String?),
      updatedAt: _parseDate(json['updated_at'] as String?),
    );
  }

  NewsTagEntity toEntity() {
    return NewsTagEntity(
      id: id,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class NewsTagResponseModel {
  final List<NewsTagModel> tags;
  final int count;

  NewsTagResponseModel({required this.tags, required this.count});

  factory NewsTagResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final tagsJson = data['blog_tags'] as List<dynamic>? ?? [];

    return NewsTagResponseModel(
      tags: tagsJson
          .map((item) => NewsTagModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      count: data['count'] as int? ?? tagsJson.length,
    );
  }
}
