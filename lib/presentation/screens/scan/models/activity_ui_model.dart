import 'package:flutter/material.dart';
import 'package:se501_plantheon/domain/entities/keyword_activity_entity.dart';

enum ActivityType { chiTieu, banSanPham, kyThuat, dichBenh, kinhKhi, khac }

class Activity {
  final String title;
  final String description;
  final ActivityType type;
  final DateTime suggestedTime;
  final DateTime endTime;
  final KeywordActivityEntity originalEntity;

  Activity({
    required this.title,
    required this.description,
    required this.type,
    required this.suggestedTime,
    required this.endTime,
    required this.originalEntity,
  });
}

class ActivityTypeConfig {
  final Color backgroundColor;
  final Color accentColor;
  final IconData icon;

  ActivityTypeConfig({
    required this.backgroundColor,
    required this.accentColor,
    required this.icon,
  });

  static ActivityTypeConfig getConfig(ActivityType type) {
    switch (type) {
      case ActivityType.chiTieu:
        return ActivityTypeConfig(
          backgroundColor: const Color(0xFFFFF3E0),
          accentColor: const Color(0xFFFF9800),
          icon: Icons.attach_money_rounded,
        );
      case ActivityType.banSanPham:
        return ActivityTypeConfig(
          backgroundColor: const Color(0xFFE8F5E9),
          accentColor: const Color(0xFF4CAF50),
          icon: Icons.shopping_cart_rounded,
        );
      case ActivityType.kyThuat:
        return ActivityTypeConfig(
          backgroundColor: const Color(0xFFEDE7F6),
          accentColor: const Color(0xFF673AB7),
          icon: Icons.engineering_rounded,
        );
      case ActivityType.dichBenh:
        return ActivityTypeConfig(
          backgroundColor: const Color(0xFFFFEBEE),
          accentColor: const Color(0xFFE53935),
          icon: Icons.coronavirus_rounded,
        );
      case ActivityType.kinhKhi:
        return ActivityTypeConfig(
          backgroundColor: const Color(0xFFE1F5FE),
          accentColor: const Color(0xFF0288D1),
          icon: Icons.cloud_rounded,
        );
      case ActivityType.khac:
        return ActivityTypeConfig(
          backgroundColor: const Color(0xFFE3F2FD),
          accentColor: const Color(0xFF2196F3),
          icon: Icons.more_horiz_rounded,
        );
    }
  }
}