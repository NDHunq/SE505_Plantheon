import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

class FarmingTipStageCard extends StatefulWidget {
  final String vectorAsset;
  final String stageLabel;
  final String stageDescription;
  final String stageTime;
  final bool isNow;
  final Widget? child; // Optional: content to show when expanded

  const FarmingTipStageCard({
    super.key,
    required this.vectorAsset,
    required this.stageLabel,
    required this.stageDescription,
    required this.stageTime,
    this.isNow = false,
    this.child,
  });

  @override
  State<FarmingTipStageCard> createState() => _FarmingTipStageCardState();
}

class _FarmingTipStageCardState extends State<FarmingTipStageCard> {
  bool isCollapsed = true;

  void _toggleCollapse() {
    setState(() {
      isCollapsed = !isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCollapse,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isNow ? AppColors.primary_300 : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: AppColors.text_color_200, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // spacing: 16, // Row does not have spacing, use SizedBox
              children: [
                SvgPicture.asset(widget.vectorAsset, width: 60, height: 60),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // spacing: 4, // Column does not have spacing, use SizedBox
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: widget.isNow
                                ? AppColors.white
                                : AppColors.text_color_200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.stageLabel,
                          style: TextStyle(
                            color: widget.isNow
                                ? AppColors.white
                                : AppColors.text_color_200,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.stageDescription,
                        style: TextStyle(
                          color: widget.isNow
                              ? AppColors.white
                              : AppColors.text_color_200,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.stageTime,
                        style: TextStyle(
                          color: widget.isNow
                              ? AppColors.white
                              : AppColors.text_color_400,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isCollapsed ? 0.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: widget.isNow
                        ? AppColors.white
                        : AppColors.text_color_50,
                  ),
                ),
              ],
            ),
            if (!isCollapsed && widget.child != null) ...[
              const SizedBox(height: 12),
              widget.child!,
            ],
          ],
        ),
      ),
    );
  }
}
