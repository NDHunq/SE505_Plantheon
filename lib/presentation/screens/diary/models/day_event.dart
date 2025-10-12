import 'package:flutter/material.dart';

class DayEvent {
  final String id;
  final int startHour;
  final int endHour;
  final String title;
  final String type;
  final bool day;
  final String? amountText;
  final Color? color;
  final DateTime realStartTime;
  final DateTime realEndTime;

  DayEvent({
    required this.id,
    required this.startHour,
    required this.endHour,
    required this.title,
    required this.type,
    required this.day,
    required this.realStartTime,
    required this.realEndTime,
    this.amountText,
    this.color,
  }) : assert(endHour >= startHour);

  int get durationHours => (endHour - startHour).clamp(1, 24);
}
