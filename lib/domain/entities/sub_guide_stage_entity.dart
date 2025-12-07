import 'package:se501_plantheon/domain/entities/blog_entity.dart';

class SubGuideStageEntity {
  final String id;
  final String guideStageId;
  final String title;
  final int startDayOffset;
  final int endDayOffset;
  final List<BlogEntity> blogs;

  SubGuideStageEntity({
    required this.id,
    required this.guideStageId,
    required this.title,
    required this.startDayOffset,
    required this.endDayOffset,
    required this.blogs,
  });
}
