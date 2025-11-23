class KeywordActivityEntity {
  final String id;
  final String name;
  final String description;
  final String type; // TREATMENT, PREVENTION, etc.
  final int baseDaysOffset;
  final bool isFreeTime;
  final int hourTime;
  final int endHourTime;
  final int timeDuration;
  final DateTime createdAt;
  final DateTime updatedAt;

  KeywordActivityEntity({
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
}
