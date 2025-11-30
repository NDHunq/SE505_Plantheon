import 'package:se501_plantheon/domain/entities/activities_entities.dart';

class ActivityModel {
  final String title;
  final String type;

  ActivityModel({required this.title, required this.type});

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(title: json['title'] ?? '', type: json['type'] ?? '');
  }

  ActivityEntity toEntity() => ActivityEntity(title: title, type: type);
}

class DayActivitiesModel {
  final DateTime date;
  final List<ActivityModel> activities;

  DayActivitiesModel({required this.date, required this.activities});

  factory DayActivitiesModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['activities'] ?? [];
    return DayActivitiesModel(
      date: DateTime.parse(json['date'] as String),
      activities: list.map((e) => ActivityModel.fromJson(e)).toList(),
    );
  }

  DayActivitiesEntity toEntity() => DayActivitiesEntity(
    date: date,
    activities: activities.map((e) => e.toEntity()).toList(),
  );
}

class MonthActivitiesModel {
  final int year;
  final int month;
  final int count;
  final List<DayActivitiesModel> days;

  MonthActivitiesModel({
    required this.year,
    required this.month,
    required this.count,
    required this.days,
  });

  factory MonthActivitiesModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final List<dynamic> dayList = data['days'] ?? [];
    return MonthActivitiesModel(
      year: data['year'] as int,
      month: data['month'] as int,
      count: data['count'] as int,
      days: dayList.map((e) => DayActivitiesModel.fromJson(e)).toList(),
    );
  }

  MonthActivitiesEntity toEntity() => MonthActivitiesEntity(
    year: year,
    month: month,
    count: count,
    days: days.map((e) => e.toEntity()).toList(),
  );
}

class DayActivityDetailModel {
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

  DayActivityDetailModel({
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

  factory DayActivityDetailModel.fromJson(Map<String, dynamic> json) {
    // Parse datetime as local time, remove 'Z' if exists
    String parseLocalDateTime(String dateTimeStr) {
      // Remove 'Z' suffix if exists to parse as local time
      return dateTimeStr.endsWith('Z')
          ? dateTimeStr.substring(0, dateTimeStr.length - 1)
          : dateTimeStr;
    }

    return DayActivityDetailModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String? ?? '',
      timeStart: DateTime.parse(
        parseLocalDateTime(json['time_start'] as String),
      ),
      timeEnd: DateTime.parse(parseLocalDateTime(json['time_end'] as String)),
      day: json['day'] as bool? ?? false,
      repeat: json['repeat'] as String?,
      isRepeat: json['is_repeat'] as String?,
      endRepeatDay: json['end_repeat_day'] != null
          ? DateTime.parse(parseLocalDateTime(json['end_repeat_day'] as String))
          : null,
      alertTime: json['alert_time'] as String?,
      description: json['description'] as String?,
      description2: json['description2'] as String?,
      description3: json['description3'] as String?,
      object: json['object'] as String?,
      unit: json['unit'] as String?,
      amount: json['amount'] != null
          ? (json['amount'] as num).toDouble()
          : null,
      targetPerson: json['target_person'] as String?,
      sourcePerson: json['source_person'] as String?,
      note: json['note'] as String?,
      money: json['money'] != null ? (json['money'] as num).toDouble() : null,
      purpose: json['purpose'] as String?,
      attachedLink: json['attached_link'] as String?,
    );
  }

  DayActivityDetailEntity toEntity() => DayActivityDetailEntity(
    id: id,
    title: title,
    type: type,
    timeStart: timeStart,
    timeEnd: timeEnd,
    day: day,
    repeat: repeat,
    isRepeat: isRepeat,
    endRepeatDay: endRepeatDay,
    alertTime: alertTime,
    description: description,
    description2: description2,
    description3: description3,
    object: object,
    unit: unit,
    amount: amount,
    targetPerson: targetPerson,
    sourcePerson: sourcePerson,
    note: note,
    money: money,
    purpose: purpose,
    attachedLink: attachedLink,
  );
}

class DayActivitiesOfDayModel {
  final DateTime date;
  final int count;
  final List<DayActivityDetailModel> activities;

  DayActivitiesOfDayModel({
    required this.date,
    required this.count,
    required this.activities,
  });

  factory DayActivitiesOfDayModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final List<dynamic> list = data['activities'] ?? [];
    return DayActivitiesOfDayModel(
      date: DateTime.parse(data['date'] as String),
      count: data['count'] as int,
      activities: list.map((e) => DayActivityDetailModel.fromJson(e)).toList(),
    );
  }

  DayActivitiesOfDayEntity toEntity() => DayActivitiesOfDayEntity(
    date: date,
    count: count,
    activities: activities.map((e) => e.toEntity()).toList(),
  );
}

class CreateActivityRequestModel {
  final String title;
  final String type;
  final String? description;
  final String? description2;
  final String? description3;
  final String? timeStart; // ISO8601 format
  final String? timeEnd; // ISO8601 format
  final bool? day; // true = all-day; false/null = không all-day
  final double? money;
  final String? repeat;
  final String? isRepeat;
  final String? endRepeatDay; // ISO8601 format
  final String? alertTime;
  final String? object;
  final double? amount;
  final String? unit;
  final String? purpose;
  final String? targetPerson;
  final String? sourcePerson;
  final String? attachedLink;
  final String? note;

  CreateActivityRequestModel({
    required this.title,
    required this.type,
    this.description,
    this.description2,
    this.description3,
    this.timeStart,
    this.timeEnd,
    this.day,
    this.money,
    this.repeat,
    this.isRepeat,
    this.endRepeatDay,
    this.alertTime,
    this.object,
    this.amount,
    this.unit,
    this.purpose,
    this.targetPerson,
    this.sourcePerson,
    this.attachedLink,
    this.note,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'title': title, 'type': type};

    if (description != null) json['description'] = description;
    if (description2 != null) json['description2'] = description2;
    if (description3 != null) json['description3'] = description3;
    if (timeStart != null) json['time_start'] = timeStart;
    if (timeEnd != null) json['time_end'] = timeEnd;
    if (day != null) json['day'] = day;
    if (money != null) json['money'] = money;
    if (repeat != null) json['repeat'] = repeat;
    if (isRepeat != null) json['is_repeat'] = isRepeat;
    if (endRepeatDay != null) json['end_repeat_day'] = endRepeatDay;
    if (alertTime != null) json['alert_time'] = alertTime;
    if (object != null) json['object'] = object;
    if (amount != null) json['amount'] = amount;
    if (unit != null) json['unit'] = unit;
    if (purpose != null) json['purpose'] = purpose;
    if (targetPerson != null) json['target_person'] = targetPerson;
    if (sourcePerson != null) json['source_person'] = sourcePerson;
    if (attachedLink != null) json['attached_link'] = attachedLink;
    if (note != null) json['note'] = note;

    return json;
  }
}

class CreateActivityResponseModel {
  final String id;
  final String message;

  CreateActivityResponseModel({required this.id, required this.message});

  factory CreateActivityResponseModel.fromJson(Map<String, dynamic> json) {
    String id = '';
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      id = json['data']['id'] as String? ?? '';
    } else {
      id = json['id'] as String? ?? '';
    }

    return CreateActivityResponseModel(
      id: id,
      message: json['message'] as String? ?? 'Activity created successfully',
    );
  }
}
