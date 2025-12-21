import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_svg/svg.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/constants/constraints.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';

/// Custom Navigation Bar dựa theo thiết kế Diary với nút back và 3 nút chức năng bên phải
class CustomNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
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
  Size get preferredSize => Size.fromHeight(AppConstraints.appBarHeight.sp);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstraints.appBarHeight.sp,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            Theme.of(context).appBarTheme.backgroundColor ??
            Colors.white,
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation!,
                  offset: Offset(0, 2.sp),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstraints.mainPadding.sp,
          ),
          child: Row(
            children: [
              // Nút Back
              if (showBackButton) ...[
                _buildBackButton(context),
                SizedBox(width: AppConstraints.smallPadding.sp),
              ],

              // Title với khả năng tap (như trong Diary)
              Expanded(child: titleWidget ?? _buildTitle(context)),

              // Actions bên phải (tối đa 3 nút)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: actions
                    .take(3)
                    .map((action) => _buildActionButton(context, action))
                    .toList(),
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
              fontSize: AppConstraints.titleSmallFontSize.sp,
              fontWeight: FontWeight.bold,
              color:
                  textColor ??
                  Theme.of(context).textTheme.titleLarge?.color ??
                  AppColors.primary_600,
            ),
          ),
          if (showYearSelector) ...[
            SizedBox(width: 4.sp),
            Icon(
              showYearSelector
                  ? Icons.arrow_drop_up_rounded
                  : Icons.arrow_drop_down_rounded,
              color:
                  iconColor ??
                  Theme.of(context).iconTheme.color ??
                  Colors.white,
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
      child: SvgPicture.asset(
        AppVectors.arrowBack,
        width: 30.sp,
        height: 30.sp,
        color: AppColors.primary_600,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, NavigationAction action) {
    return Padding(
      padding: EdgeInsets.only(left: AppConstraints.smallPadding.sp),
      child: GestureDetector(
        onTap: () async {
          if (action.onPressed != null) {
            // Show loading briefly for action
            await Future.delayed(const Duration(milliseconds: 200));
            action.onPressed!();
          }
        },
        child: SizedBox(
          width: 30.sp,
          height: 30.sp,

          child: action.svgAsset != null
              ? SvgPicture.asset(
                  action.svgAsset!,
                  width: AppConstraints.mediumIconSize.sp,
                  height: AppConstraints.mediumIconSize.sp,
                  color: AppColors.primary_600,
                )
              : (action.icon != null
                    ? Icon(
                        action.icon,
                        size: AppConstraints.mediumIconSize.sp,
                        color: AppColors.primary_600,
                      )
                    : action.child),
        ),
      ),
    );
  }
}

/// Class định nghĩa action cho navigation bar
class NavigationAction {
  final IconData? icon;
  final String? svgAsset;
  final Widget? child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? borderColor;
  final String? tooltip;

  const NavigationAction({
    this.icon,
    this.svgAsset,
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

  /// Tạo action với SVG asset
  factory NavigationAction.svg({
    required String svgAsset,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
    Color? borderColor,
    String? tooltip,
  }) {
    return NavigationAction(
      svgAsset: svgAsset,
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
class DiaryNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int selectedYear;
  final int? selectedMonth;
  final bool showYearSelector;
  final VoidCallback onToggleYearSelector;
  final VoidCallback? onBackPressed;
  final VoidCallback? onBackToMonthSelection;
  final List<NavigationAction> actions;
  final bool showBackButton;
  final String? customTitle;

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
    this.customTitle,
  });

  @override
  Size get preferredSize => Size.fromHeight(AppConstraints.appBarHeight.sp);

  @override
  Widget build(BuildContext context) {
    // Nếu có customTitle, sử dụng customTitle
    // Nếu không, sử dụng logic cũ
    final String titleText;
    final VoidCallback? titleTapCallback;

    if (customTitle != null) {
      titleText = customTitle!;
      titleTapCallback = null; // Không cho phép tap khi có custom title
    } else {
      // Logic cũ
      final bool isMonthMode = selectedMonth != null;
      titleText = isMonthMode
          ? "Tháng $selectedMonth $selectedYear"
          : "$selectedYear";

      // Chỉ cho phép tap title khi không ở chế độ tháng
      titleTapCallback = (selectedMonth == null) ? onToggleYearSelector : null;
    }

    return CustomNavigationBar(
      title: titleText,
      backgroundColor: AppColors.white,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      showYearSelector: customTitle == null
          ? (showYearSelector && (selectedMonth == null))
          : false,
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
                    style: TextStyle(
                      fontSize: AppConstraints.titleMediumFontSize.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (selectedMonth == null) ...[
                    SizedBox(width: 4.sp),
                    Icon(
                      showYearSelector
                          ? Icons.arrow_drop_up_rounded
                          : Icons.arrow_drop_down_rounded,
                    ),
                  ],
                ],
              ),
            )
          : Text(
              titleText,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
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
      icon: Icons.add_rounded,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.primary_main,
      iconColor: iconColor ?? Colors.white,
    );
  }

  /// Nút chỉnh sửa
  static NavigationAction edit({
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return NavigationAction.svg(
      svgAsset: AppVectors.userEdit,
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
    return NavigationAction.svg(
      svgAsset: AppVectors.trash,
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
      backgroundColor: backgroundColor ?? AppColors.primary_main,
      iconColor: iconColor ?? Colors.white,
    );
  }

  /// Nút chia sẻ
  static NavigationAction share({
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return NavigationAction.svg(
      svgAsset: AppVectors.share,
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
    return NavigationAction.svg(
      svgAsset: AppVectors.search,
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
    return NavigationAction.svg(
      svgAsset: AppVectors.reload,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.blue,
      iconColor: iconColor ?? Colors.white,
    );
  }
}
