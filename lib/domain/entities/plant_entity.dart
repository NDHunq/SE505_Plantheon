class PlantEntity {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlantEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}
