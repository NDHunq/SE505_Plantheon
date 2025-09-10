import 'package:flutter/material.dart';
import 'package:se501_plantheon/shared/constraint.dart';

/// Custom Navigation Bar dựa theo thiết kế Diary với nút back và 3 nút chức năng bên phải
class CustomNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<NavigationAction> actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? elevation;
  final bool showYearSelector;
  final VoidCallback? onTitleTap;
  final Widget? titleWidget;

  const CustomNavigationBar({
    super.key,
    required this.title,
    this.onBackPressed,
    required this.actions,
    this.showBackButton = true,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.elevation,
    this.showYearSelector = false,
    this.onTitleTap,
    this.titleWidget,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppConstraints.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstraints.appBarHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation!,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstraints.mainPadding,
          ),
          child: Row(
            children: [
              // Nút Back
              if (showBackButton) ...[
                _buildBackButton(context),
                const SizedBox(width: AppConstraints.smallPadding),
              ],
              
              // Title với khả năng tap (như trong Diary)
              Expanded(
                child: titleWidget ?? _buildTitle(context),
              ),
              
              // Actions bên phải (tối đa 3 nút)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: actions.take(3).map((action) => _buildActionButton(context, action)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return GestureDetector(
      onTap: onTitleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstraints.titleLargeFontSize,
              fontWeight: FontWeight.bold,
              color: textColor ?? Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
            ),
          ),
          if (showYearSelector) ...[
            const SizedBox(width: 4),
            Icon(
              showYearSelector ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: iconColor ?? Theme.of(context).iconTheme.color ?? Colors.black,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (onBackPressed != null) {
          // Show loading briefly for back action
          await Future.delayed(const Duration(milliseconds: 200));
          onBackPressed!();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: AppConstraints.mediumIconSize,
          color: iconColor ?? Theme.of(context).iconTheme.color ?? Colors.black,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, NavigationAction action) {
    return Padding(
      padding: const EdgeInsets.only(left: AppConstraints.smallPadding),
      child: GestureDetector(
        onTap: () async {
          if (action.onPressed != null) {
            // Show loading briefly for action
            await Future.delayed(const Duration(milliseconds: 200));
            action.onPressed!();
          }
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: action.backgroundColor ?? Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstraints.mediumBorderRadius),
            border: action.borderColor != null
                ? Border.all(color: action.borderColor!, width: 1)
                : null,
          ),
          child: action.icon != null
              ? Icon(
                  action.icon,
                  size: AppConstraints.mediumIconSize,
                  color: action.iconColor ?? iconColor ?? Theme.of(context).iconTheme.color ?? Colors.black,
                )
              : action.child,
        ),
      ),
    );
  }
}

/// Class định nghĩa action cho navigation bar
class NavigationAction {
  final IconData? icon;
  final Widget? child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? borderColor;
  final String? tooltip;

  const NavigationAction({
    this.icon,
    this.child,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.borderColor,
    this.tooltip,
  });

  /// Tạo action với icon
  factory NavigationAction.icon({
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
    Color? borderColor,
    String? tooltip,
  }) {
    return NavigationAction(
      icon: icon,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      borderColor: borderColor,
      tooltip: tooltip,
    );
  }

  /// Tạo action với custom widget
  factory NavigationAction.custom({
    required Widget child,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? borderColor,
    String? tooltip,
  }) {
    return NavigationAction(
      child: child,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      tooltip: tooltip,
    );
  }
}

/// Diary Navigation Bar - Dựa theo thiết kế Diary hiện tại
class DiaryNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedYear;
  final int? selectedMonth;
  final bool showYearSelector;
  final VoidCallback onToggleYearSelector;
  final VoidCallback? onBackPressed;
  final VoidCallback? onBackToMonthSelection;
  final List<NavigationAction> actions;
  final bool showBackButton;

  const DiaryNavigationBar({
    super.key,
    required this.selectedYear,
    this.selectedMonth,
    required this.showYearSelector,
    required this.onToggleYearSelector,
    this.onBackPressed,
    this.onBackToMonthSelection,
    required this.actions,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppConstraints.appBarHeight);

  @override
  Widget build(BuildContext context) {
    // Nếu đang ở chế độ tháng, hiển thị "Tháng X năm Y"
    final bool isMonthMode = selectedMonth != null;
    final String titleText = isMonthMode 
        ? "Tháng $selectedMonth $selectedYear"
        : "$selectedYear";
    
    // Chỉ cho phép tap title khi không ở chế độ tháng
    final VoidCallback? titleTapCallback = !isMonthMode 
        ? onToggleYearSelector 
        : null;

    return CustomNavigationBar(
      title: titleText,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      showYearSelector: showYearSelector && !isMonthMode,
      onTitleTap: titleTapCallback,
      actions: actions,
      titleWidget: titleTapCallback != null 
          ? GestureDetector(
              onTap: titleTapCallback,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isMonthMode) ...[
                    const SizedBox(width: 4),
                    Icon(
                      showYearSelector ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    ),
                  ],
                ],
              ),
            )
          : Text(
              titleText,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

/// Predefined actions cho các chức năng thường dùng
class CommonNavigationActions {
  /// Nút thêm mới
  static NavigationAction add({
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return NavigationAction.icon(
      icon: Icons.add,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.green,
      iconColor: iconColor ?? Colors.white,
    );
  }

  /// Nút chỉnh sửa
  static NavigationAction edit({
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return NavigationAction.icon(
      icon: Icons.edit,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.blue,
      iconColor: iconColor ?? Colors.white,
    );
  }

  /// Nút xóa
  static NavigationAction delete({
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return NavigationAction.icon(
      icon: Icons.delete,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.red,
      iconColor: iconColor ?? Colors.white,
    );
  }

  /// Nút lưu
  static NavigationAction save({
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return NavigationAction.icon(
      icon: Icons.save,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.green,
      iconColor: iconColor ?? Colors.white,
    );
  }

  /// Nút chia sẻ
  static NavigationAction share({
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return NavigationAction.icon(
      icon: Icons.share,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.orange,
      iconColor: iconColor ?? Colors.white,
    );
  }

  /// Nút tìm kiếm
  static NavigationAction search({
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return NavigationAction.icon(
      icon: Icons.search,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.purple,
      iconColor: iconColor ?? Colors.white,
    );
  }

  /// Nút menu
  static NavigationAction menu({
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return NavigationAction.icon(
      icon: Icons.more_vert,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.grey,
      iconColor: iconColor ?? Colors.white,
    );
  }

  /// Nút refresh
  static NavigationAction refresh({
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return NavigationAction.icon(
      icon: Icons.refresh,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.blue,
      iconColor: iconColor ?? Colors.white,
    );
  }
}
