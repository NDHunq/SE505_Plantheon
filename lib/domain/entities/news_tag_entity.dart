class NewsTagEntity {
  final String id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NewsTagEntity({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });
}
