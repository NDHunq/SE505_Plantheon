class NewsEntity {
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

  NewsEntity({
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
}
