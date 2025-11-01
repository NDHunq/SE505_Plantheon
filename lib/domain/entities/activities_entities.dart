class ActivityEntity {
  final String title;
  final String type;

  ActivityEntity({required this.title, required this.type});
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
  final bool day;
  final String? repeat;
  final String? isRepeat;
  final DateTime? endRepeatDay;
  final String? alertTime;
  final String? description;
  final String? description2;
  final String? description3;
  final String? object;
  final String? unit;
  final double? amount;
  final String? targetPerson;
  final String? sourcePerson;
  final String? note;
  final double? money;
  final String? purpose;
  final String? attachedLink;

  DayActivityDetailEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.timeStart,
    required this.timeEnd,
    required this.day,
    this.repeat,
    this.isRepeat,
    this.endRepeatDay,
    this.alertTime,
    this.description,
    this.description2,
    this.description3,
    this.object,
    this.unit,
    this.amount,
    this.targetPerson,
    this.sourcePerson,
    this.note,
    this.money,
    this.purpose,
    this.attachedLink,
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
