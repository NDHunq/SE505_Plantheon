import 'package:flutter/material.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';

class TaskWidget extends StatelessWidget {
  final String title;
  final String? amountText;
  final String startTime;
  final String endTime;
  final Color? baseColor;
  final bool isShort;

  const TaskWidget({
    super.key,
    required this.title,
    this.amountText,
    required this.startTime,
    required this.endTime,
    this.baseColor,
    this.isShort = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color taskColor = baseColor ?? Colors.blue;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
      child: Container(
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.only(right: 8, top: 0, bottom: 0),
        padding: EdgeInsets.symmetric(
          horizontal: AppConstraints.smallPadding,
          vertical: isShort ? 6 : AppConstraints.smallPadding,
        ),
        decoration: BoxDecoration(
          color: taskColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(
            AppConstraints.mediumBorderRadius,
          ),
          border: Border(left: BorderSide(color: taskColor, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              maxLines: isShort ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppConstraints.normalTextFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Amount text (if provided)
            if (amountText != null) ...[
              SizedBox(height: isShort ? 1 : 2),
              Text(
                amountText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppConstraints.smallTextFontSize,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            // Time
            SizedBox(height: isShort ? 2 : 4),
            Text(
              '$startTime - $endTime',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppConstraints.smallTextFontSize,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Factory constructors for different task types
extension TaskWidgetFactory on TaskWidget {
  static TaskWidget expense({
    required String title,
    required String amount,
    required String startTime,
    required String endTime,
    bool isShort = false,
  }) {
    return TaskWidget(
      title: title,
      amountText: amount,
      startTime: startTime,
      endTime: endTime,
      baseColor: Colors.red,
      isShort: isShort,
    );
  }

  static TaskWidget income({
    required String title,
    required String amount,
    required String startTime,
    required String endTime,
    bool isShort = false,
  }) {
    return TaskWidget(
      title: title,
      amountText: amount,
      startTime: startTime,
      endTime: endTime,
      baseColor: Colors.green,
      isShort: isShort,
    );
  }

  static TaskWidget general({
    required String title,
    required String startTime,
    required String endTime,
    Color? color,
    bool isShort = false,
  }) {
    return TaskWidget(
      title: title,
      startTime: startTime,
      endTime: endTime,
      baseColor: color ?? Colors.blue,
      isShort: isShort,
    );
  }
}
