class MonthlyFinancialEntity {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final List<FinancialActivityEntity> activities;

  MonthlyFinancialEntity({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.activities,
  });
}

class FinancialActivityEntity {
  final String id;
  final String? description;
  final String? description2;
  final String? description3;
  final DateTime timeStart;
  final DateTime timeEnd;
  final bool day;
  final double? money;
  final String type;
  final String title;
  final String? isRepeat;
  final String? repeat;
  final DateTime? endRepeatDay;
  final String? alertTime;
  final String? object;
  final double? amount;
  final String? unit;
  final String? purpose;
  final String? targetPerson;
  final String? sourcePerson;
  final String? attachedLink;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinancialActivityEntity({
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
}

class AnnualFinancialEntity {
  final int year;
  final List<MonthlySummaryEntity> monthlySummaries;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;

  AnnualFinancialEntity({
    required this.year,
    required this.monthlySummaries,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
  });
}

class MonthlySummaryEntity {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;

  MonthlySummaryEntity({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
  });
}

class MultiYearFinancialEntity {
  final int startYear;
  final int endYear;
  final List<YearlySummaryEntity> yearlySummaries;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;

  MultiYearFinancialEntity({
    required this.startYear,
    required this.endYear,
    required this.yearlySummaries,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
  });
}

class YearlySummaryEntity {
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;

  YearlySummaryEntity({
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
  });
}
