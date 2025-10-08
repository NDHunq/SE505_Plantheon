class ActivityEntity {
  final String title;

  ActivityEntity({required this.title});
}

class DayActivitiesEntity {
  final DateTime date;
  final List<ActivityEntity> activities;

  DayActivitiesEntity({required this.date, required this.activities});
}

class MonthActivitiesEntity {
  final int year;
  final int month;
  final int count;
  final List<DayActivitiesEntity> days;

  MonthActivitiesEntity({
    required this.year,
    required this.month,
    required this.count,
    required this.days,
  });
}

class DayActivityDetailEntity {
  final String id;
  final String title;
  final String type;
  final DateTime timeStart;
  final DateTime timeEnd;

  DayActivityDetailEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.timeStart,
    required this.timeEnd,
  });
}

class DayActivitiesOfDayEntity {
  final DateTime date;
  final int count;
  final List<DayActivityDetailEntity> activities;

  DayActivitiesOfDayEntity({
    required this.date,
    required this.count,
    required this.activities,
  });
}
