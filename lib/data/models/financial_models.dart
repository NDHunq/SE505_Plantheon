import 'package:se501_plantheon/domain/entities/financial_entities.dart';

class MonthlyFinancialResponseModel {
  final MonthlyFinancialDataModel data;

  MonthlyFinancialResponseModel({required this.data});

  factory MonthlyFinancialResponseModel.fromJson(Map<String, dynamic> json) {
    return MonthlyFinancialResponseModel(
      data: MonthlyFinancialDataModel.fromJson(json['data']),
    );
  }

  MonthlyFinancialEntity toEntity() {
    return data.toEntity();
  }
}

class MonthlyFinancialDataModel {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final List<FinancialActivityModel> activities;

  MonthlyFinancialDataModel({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.activities,
  });

  factory MonthlyFinancialDataModel.fromJson(Map<String, dynamic> json) {
    return MonthlyFinancialDataModel(
      year: json['year'] as int,
      month: json['month'] as int,
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpense: (json['total_expense'] as num).toDouble(),
      netAmount: (json['net_amount'] as num).toDouble(),
      activities: (json['activities'] as List)
          .map((activity) => FinancialActivityModel.fromJson(activity))
          .toList(),
    );
  }

  MonthlyFinancialEntity toEntity() {
    return MonthlyFinancialEntity(
      year: year,
      month: month,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netAmount: netAmount,
      activities: activities.map((a) => a.toEntity()).toList(),
    );
  }
}

class FinancialActivityModel {
  final String id;
  final String? description;
  final String? description2;
  final String? description3;
  final String timeStart;
  final String timeEnd;
  final bool day;
  final double? money;
  final String type;
  final String title;
  final String? isRepeat;
  final String? repeat;
  final String? endRepeatDay;
  final String? alertTime;
  final String? object;
  final double? amount;
  final String? unit;
  final String? purpose;
  final String? targetPerson;
  final String? sourcePerson;
  final String? attachedLink;
  final String? note;
  final String createdAt;
  final String updatedAt;

  FinancialActivityModel({
    required this.id,
    this.description,
    this.description2,
    this.description3,
    required this.timeStart,
    required this.timeEnd,
    required this.day,
    this.money,
    required this.type,
    required this.title,
    this.isRepeat,
    this.repeat,
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinancialActivityModel.fromJson(Map<String, dynamic> json) {
    return FinancialActivityModel(
      id: json['id'] as String,
      description: json['description'] as String?,
      description2: json['description2'] as String?,
      description3: json['description3'] as String?,
      timeStart: json['time_start'] as String,
      timeEnd: json['time_end'] as String,
      day: json['day'] as bool,
      money: json['money'] != null ? (json['money'] as num).toDouble() : null,
      type: json['type'] as String,
      title: json['title'] as String,
      isRepeat: json['is_repeat'] as String?,
      repeat: json['repeat'] as String?,
      endRepeatDay: json['end_repeat_day'] as String?,
      alertTime: json['alert_time'] as String?,
      object: json['object'] as String?,
      amount: json['amount'] != null
          ? (json['amount'] as num).toDouble()
          : null,
      unit: json['unit'] as String?,
      purpose: json['purpose'] as String?,
      targetPerson: json['target_person'] as String?,
      sourcePerson: json['source_person'] as String?,
      attachedLink: json['attached_link'] as String?,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  FinancialActivityEntity toEntity() {
    return FinancialActivityEntity(
      id: id,
      description: description,
      description2: description2,
      description3: description3,
      timeStart: DateTime.parse(timeStart),
      timeEnd: DateTime.parse(timeEnd),
      day: day,
      money: money,
      type: type,
      title: title,
      isRepeat: isRepeat,
      repeat: repeat,
      endRepeatDay: endRepeatDay != null ? DateTime.parse(endRepeatDay!) : null,
      alertTime: alertTime,
      object: object,
      amount: amount,
      unit: unit,
      purpose: purpose,
      targetPerson: targetPerson,
      sourcePerson: sourcePerson,
      attachedLink: attachedLink,
      note: note,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}

// Annual Financial Models
class AnnualFinancialResponseModel {
  final AnnualFinancialDataModel data;

  AnnualFinancialResponseModel({required this.data});

  factory AnnualFinancialResponseModel.fromJson(Map<String, dynamic> json) {
    return AnnualFinancialResponseModel(
      data: AnnualFinancialDataModel.fromJson(json['data']),
    );
  }

  AnnualFinancialEntity toEntity() {
    return data.toEntity();
  }
}

class AnnualFinancialDataModel {
  final int year;
  final List<MonthlySummaryModel> monthlySummaries;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;

  AnnualFinancialDataModel({
    required this.year,
    required this.monthlySummaries,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
  });

  factory AnnualFinancialDataModel.fromJson(Map<String, dynamic> json) {
    return AnnualFinancialDataModel(
      year: json['year'] as int,
      monthlySummaries: (json['monthly_summaries'] as List)
          .map((summary) => MonthlySummaryModel.fromJson(summary))
          .toList(),
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpense: (json['total_expense'] as num).toDouble(),
      netAmount: (json['net_amount'] as num).toDouble(),
    );
  }

  AnnualFinancialEntity toEntity() {
    return AnnualFinancialEntity(
      year: year,
      monthlySummaries: monthlySummaries.map((m) => m.toEntity()).toList(),
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netAmount: netAmount,
    );
  }
}

class MonthlySummaryModel {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;

  MonthlySummaryModel({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
  });

  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryModel(
      year: json['year'] as int,
      month: json['month'] as int,
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpense: (json['total_expense'] as num).toDouble(),
      netAmount: (json['net_amount'] as num).toDouble(),
    );
  }

  MonthlySummaryEntity toEntity() {
    return MonthlySummaryEntity(
      year: year,
      month: month,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netAmount: netAmount,
    );
  }
}

class MultiYearFinancialResponseModel {
  final MultiYearFinancialDataModel data;

  MultiYearFinancialResponseModel({required this.data});

  factory MultiYearFinancialResponseModel.fromJson(Map<String, dynamic> json) {
    return MultiYearFinancialResponseModel(
      data: MultiYearFinancialDataModel.fromJson(json['data']),
    );
  }

  MultiYearFinancialEntity toEntity() {
    return data.toEntity();
  }
}

class MultiYearFinancialDataModel {
  final int startYear;
  final int endYear;
  final List<YearlySummaryModel> yearlySummaries;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;

  MultiYearFinancialDataModel({
    required this.startYear,
    required this.endYear,
    required this.yearlySummaries,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
  });

  factory MultiYearFinancialDataModel.fromJson(Map<String, dynamic> json) {
    return MultiYearFinancialDataModel(
      startYear: json['start_year'] as int,
      endYear: json['end_year'] as int,
      yearlySummaries: (json['yearly_summaries'] as List)
          .map((summary) => YearlySummaryModel.fromJson(summary))
          .toList(),
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpense: (json['total_expense'] as num).toDouble(),
      netAmount: (json['net_amount'] as num).toDouble(),
    );
  }

  MultiYearFinancialEntity toEntity() {
    return MultiYearFinancialEntity(
      startYear: startYear,
      endYear: endYear,
      yearlySummaries: yearlySummaries.map((y) => y.toEntity()).toList(),
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netAmount: netAmount,
    );
  }
}

class YearlySummaryModel {
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;

  YearlySummaryModel({
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
  });

  factory YearlySummaryModel.fromJson(Map<String, dynamic> json) {
    return YearlySummaryModel(
      year: json['year'] as int,
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpense: (json['total_expense'] as num).toDouble(),
      netAmount: (json['net_amount'] as num).toDouble(),
    );
  }

  YearlySummaryEntity toEntity() {
    return YearlySummaryEntity(
      year: year,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netAmount: netAmount,
    );
  }
}
