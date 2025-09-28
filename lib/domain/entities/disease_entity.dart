class DiseaseEntity {
  final String id;
  final String name;
  final String type;
  final String description;
  final List<String> imageLink;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String className;
  final String plantName;
  final String solution;

  DiseaseEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.imageLink,
    required this.createdAt,
    required this.updatedAt,
    required this.className,
    required this.plantName,
    required this.solution,
  });
}
