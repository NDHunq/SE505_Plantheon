class PlantModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class GetPlantsResponseModel {
  final int count;
  final List<PlantModel> plants;

  GetPlantsResponseModel({required this.count, required this.plants});

  factory GetPlantsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final plantsJson = data['plants'] as List<dynamic>? ?? [];

    return GetPlantsResponseModel(
      count: data['count'] as int? ?? plantsJson.length,
      plants: plantsJson
          .map((item) => PlantModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'count': count,
        'plants': plants.map((plant) => plant.toJson()).toList(),
      },
    };
  }
}
