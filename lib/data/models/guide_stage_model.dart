import 'package:se501_plantheon/domain/entities/blog_entity.dart';
import 'package:se501_plantheon/domain/entities/guide_stage_detail_entity.dart';
import 'package:se501_plantheon/domain/entities/guide_stage_entity.dart';
import 'package:se501_plantheon/domain/entities/sub_guide_stage_entity.dart';

class GuideStageModel {
  final String id;
  final String plantId;
  final String stageTitle;
  final String description;
  final int startDayOffset;
  final int endDayOffset;
  final String imageUrl;
  final DateTime createdAt;

  GuideStageModel({
    required this.id,
    required this.plantId,
    required this.stageTitle,
    required this.description,
    required this.startDayOffset,
    required this.endDayOffset,
    required this.imageUrl,
    required this.createdAt,
  });

  factory GuideStageModel.fromJson(Map<String, dynamic> json) {
    return GuideStageModel(
      id: json['id'] as String? ?? '',
      plantId: json['plant_id'] as String? ?? '',
      stageTitle: json['stage_title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startDayOffset: json['start_day_offset'] as int? ?? 0,
      endDayOffset: json['end_day_offset'] as int? ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plant_id': plantId,
      'stage_title': stageTitle,
      'description': description,
      'start_day_offset': startDayOffset,
      'end_day_offset': endDayOffset,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  GuideStageEntity toEntity() {
    return GuideStageEntity(
      id: id,
      plantId: plantId,
      stageTitle: stageTitle,
      description: description,
      startDayOffset: startDayOffset,
      endDayOffset: endDayOffset,
      imageUrl: imageUrl,
      createdAt: createdAt,
    );
  }
}

class GetGuideStagesResponseModel {
  final int count;
  final List<GuideStageModel> guideStages;

  GetGuideStagesResponseModel({required this.count, required this.guideStages});

  factory GetGuideStagesResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final stagesJson = data['guide_stages'] as List<dynamic>? ?? [];

    return GetGuideStagesResponseModel(
      count: data['count'] as int? ?? stagesJson.length,
      guideStages: stagesJson
          .map((item) => GuideStageModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BlogModel {
  final String title;
  final String content;
  final String coverImageUrl;

  BlogModel({
    required this.title,
    required this.content,
    required this.coverImageUrl,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      coverImageUrl: json['cover_image_url'] as String? ?? '',
    );
  }

  BlogEntity toEntity() {
    return BlogEntity(
      title: title,
      content: content,
      coverImageUrl: coverImageUrl,
    );
  }
}

class SubGuideStageModel {
  final String id;
  final String guideStageId;
  final String title;
  final int startDayOffset;
  final int endDayOffset;
  final List<BlogModel> blogs;

  SubGuideStageModel({
    required this.id,
    required this.guideStageId,
    required this.title,
    required this.startDayOffset,
    required this.endDayOffset,
    required this.blogs,
  });

  factory SubGuideStageModel.fromJson(Map<String, dynamic> json) {
    final blogsJson = json['blogs'] as List<dynamic>? ?? [];
    return SubGuideStageModel(
      id: json['id'] as String? ?? '',
      guideStageId: json['guide_stages_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      startDayOffset: json['start_day_offset'] as int? ?? 0,
      endDayOffset: json['end_day_offset'] as int? ?? 0,
      blogs: blogsJson
          .map((item) => BlogModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  SubGuideStageEntity toEntity() {
    return SubGuideStageEntity(
      id: id,
      guideStageId: guideStageId,
      title: title,
      startDayOffset: startDayOffset,
      endDayOffset: endDayOffset,
      blogs: blogs.map((b) => b.toEntity()).toList(),
    );
  }
}

class GuideStageDetailModel extends GuideStageModel {
  final List<SubGuideStageModel> subGuideStages;

  GuideStageDetailModel({
    required super.id,
    required super.plantId,
    required super.stageTitle,
    required super.description,
    required super.startDayOffset,
    required super.endDayOffset,
    required super.imageUrl,
    required super.createdAt,
    required this.subGuideStages,
  });

  factory GuideStageDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final subStagesJson = data['sub_guide_stages'] as List<dynamic>? ?? [];
    return GuideStageDetailModel(
      id: data['id'] as String? ?? '',
      plantId: data['plant_id'] as String? ?? '',
      stageTitle: data['stage_title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      startDayOffset: data['start_day_offset'] as int? ?? 0,
      endDayOffset: data['end_day_offset'] as int? ?? 0,
      imageUrl: data['image_url'] as String? ?? '',
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : DateTime.now(),
      subGuideStages: subStagesJson
          .map(
            (item) => SubGuideStageModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  GuideStageDetailEntity toEntity() {
    return GuideStageDetailEntity(
      id: id,
      plantId: plantId,
      stageTitle: stageTitle,
      description: description,
      startDayOffset: startDayOffset,
      endDayOffset: endDayOffset,
      imageUrl: imageUrl,
      createdAt: createdAt,
      subGuideStages: subGuideStages.map((s) => s.toEntity()).toList(),
    );
  }
}
