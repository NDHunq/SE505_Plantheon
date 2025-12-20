import 'package:se501_plantheon/domain/entities/complaint_entity.dart';

class ComplaintModel extends ComplaintEntity {
  ComplaintModel({
    required super.targetId,
    required super.targetType,
    required super.category,
    required super.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'target_id': targetId,
      'target_type': targetType,
      'category': category,
      'content': content,
    };
  }

  factory ComplaintModel.fromEntity(ComplaintEntity entity) {
    return ComplaintModel(
      targetId: entity.targetId,
      targetType: entity.targetType,
      category: entity.category,
      content: entity.content,
    );
  }
}
