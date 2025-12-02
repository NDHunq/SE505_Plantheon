class DiseaseModel {
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

  DiseaseModel({
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

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    print('🔧 Model: Parsing JSON: $json');

    // Extract data from nested structure
    final data = json['data'] as Map<String, dynamic>? ?? json;
    print('📦 Model: Extracted data: $data');

    final model = DiseaseModel(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageLink:
          (data['image_link'] as List?)
              ?.map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : DateTime.now(),
      className: data['class_name'] as String? ?? '',
      plantName: data['plant_name'] as String? ?? '',
      solution: data['solution'] as String? ?? '',
    );
    print('🏗️ Model: Created model with name: "${model.name}"');
    return model;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'image_link': imageLink,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'class_name': className,
      'plant_name': plantName,
      'solution': solution,
    };
  }

  DiseaseModel copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    List<String>? imageLink,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? className,
    String? plantName,
    String? solution,
  }) {
    return DiseaseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      imageLink: imageLink ?? this.imageLink,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      className: className ?? this.className,
      plantName: plantName ?? this.plantName,
      solution: solution ?? this.solution,
    );
  }

  @override
  String toString() {
    return 'DiseaseModel(id: $id, name: $name, type: $type, description: $description, imageLink: $imageLink, createdAt: $createdAt, updatedAt: $updatedAt, className: $className, plantName: $plantName, solution: $solution)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiseaseModel &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.description == description &&
        other.imageLink == imageLink &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.className == className &&
        other.plantName == plantName &&
        other.solution == solution;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        description.hashCode ^
        imageLink.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        className.hashCode ^
        plantName.hashCode ^
        solution.hashCode;
  }
}
