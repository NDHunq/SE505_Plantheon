import 'package:se501_plantheon/domain/entities/keyword_activity_entity.dart';

class KeywordActivityModel {
  final String id;
  final String name;
  final String description;
  final String type;
  final int baseDaysOffset;
  final bool isFreeTime;
  final int hourTime;
  final int endHourTime;
  final int timeDuration;
  final DateTime createdAt;
  final DateTime updatedAt;

  KeywordActivityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.baseDaysOffset,
    required this.isFreeTime,
    required this.hourTime,
    required this.endHourTime,
    required this.timeDuration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KeywordActivityModel.fromJson(Map<String, dynamic> json) {
    return KeywordActivityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      baseDaysOffset: json['base_days_offset'] as int? ?? 0,
      isFreeTime: json['is_free_time'] as bool? ?? false,
      hourTime: json['hour_time'] as int? ?? 0,
      endHourTime: json['end_hour_time'] as int? ?? 0,
      timeDuration: json['time_duration'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  KeywordActivityEntity toEntity() {
    return KeywordActivityEntity(
      id: id,
      name: name,
      description: description,
      type: type,
      baseDaysOffset: baseDaysOffset,
      isFreeTime: isFreeTime,
      hourTime: hourTime,
      endHourTime: endHourTime,
      timeDuration: timeDuration,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class KeywordActivitiesResponseModel {
  final List<KeywordActivityModel> data;

  KeywordActivitiesResponseModel({required this.data});

  factory KeywordActivitiesResponseModel.fromJson(Map<String, dynamic> json) {
    return KeywordActivitiesResponseModel(
      data: (json['data'] as List)
          .map((item) => KeywordActivityModel.fromJson(item))
          .toList(),
    );
  }
}
