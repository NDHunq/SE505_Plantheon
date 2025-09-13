import 'package:flutter/material.dart';

/// File chứa các kích thước và constraints được sử dụng trong ứng dụng
class AppConstraints {
  //===========COLORS===========
  static const lightGray = Color(0xFFC4C6C8);

  // ========== PADDING & MARGIN ==========
  /// Padding chính cho các màn hình
  static const double mainPadding = 12.0;

  /// Padding nhỏ cho các widget con
  static const double smallPadding = 8.0;

  /// Padding lớn cho các container chính
  static const double largePadding = 16.0;

  /// Padding rất lớn cho các section
  static const double extraLargePadding = 24.0;

  /// Padding cho icon trong navigation
  static const double iconPaddingTop = 3.0;
  static const double iconPaddingTopLarge = 20.0;

  // ========== ICON SIZES ==========
  /// Kích thước icon trong navigation bar
  static const double navigationIconSize = 23.0;

  /// Kích thước icon nhỏ
  static const double smallIconSize = 16.0;

  /// Kích thước icon trung bình
  static const double mediumIconSize = 30.0;

  /// Kích thước icon lớn
  static const double largeIconSize = 32.0;

  // ========== TEXT SIZES ==========
  /// Font size cho title lớn
  static const double titleLargeFontSize = 24.0;

  /// Font size cho title trung bình
  static const double titleMediumFontSize = 20.0;

  /// Font size cho text nhỏ
  static const double smallTextFontSize = 10.0;

  /// Font size cho text thông thường
  static const double normalTextFontSize = 14.0;

  /// Font size cho text lớn
  static const double largeTextFontSize = 16.0;

  // ========== NAVIGATION BAR ==========
  /// Chiều cao của navigation bar
  static const double navigationBarHeight = 56.0;

  // ========== GRID & LAYOUT ==========
  /// Số cột trong grid view tháng
  static const int monthGridCrossAxisCount = 3;

  /// Số cột trong grid view ngày
  static const int dayGridCrossAxisCount = 7;

  /// Tỉ lệ aspect ratio cho month widget
  static const double monthWidgetAspectRatio = 0.9;

  /// Khoảng cách giữa các item trong grid
  static const double gridSpacing = 8.0;

  /// Khoảng cách nhỏ giữa các widget
  static const double smallSpacing = 4.0;

  // ========== BORDER RADIUS ==========
  /// Border radius nhỏ
  static const double smallBorderRadius = 4.0;

  /// Border radius trung bình
  static const double mediumBorderRadius = 8.0;

  /// Border radius lớn
  static const double largeBorderRadius = 12.0;

  /// Border radius rất lớn
  static const double extraLargeBorderRadius = 16.0;

  // ========== ELEVATION & SHADOWS ==========
  /// Elevation thấp
  static const double lowElevation = 2.0;

  /// Elevation trung bình
  static const double mediumElevation = 4.0;

  /// Elevation cao
  static const double highElevation = 8.0;

  // ========== BUTTON SIZES ==========
  /// Chiều cao button nhỏ
  static const double smallButtonHeight = 32.0;

  /// Chiều cao button trung bình
  static const double mediumButtonHeight = 44.0;

  /// Chiều cao button lớn
  static const double largeButtonHeight = 56.0;

  // ========== CARD SIZES ==========
  /// Chiều cao card nhỏ
  static const double smallCardHeight = 80.0;

  /// Chiều cao card trung bình
  static const double mediumCardHeight = 120.0;

  /// Chiều cao card lớn
  static const double largeCardHeight = 160.0;

  // ========== APP BAR ==========
  /// Chiều cao app bar mặc định
  static const double appBarHeight = 56.0;

  /// Chiều cao app bar lớn
  static const double largeAppBarHeight = 80.0;

  // ========== DIVIDER ==========
  /// Độ dày divider mỏng
  static const double thinDividerHeight = 0.5;

  /// Độ dày divider thông thường
  static const double normalDividerHeight = 1.0;

  /// Độ dày divider dày
  static const double thickDividerHeight = 2.0;

  // ========== ANIMATION DURATION ==========
  /// Thời gian animation ngắn
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);

  /// Thời gian animation trung bình
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);

  /// Thời gian animation dài
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // ========== RESPONSIVE BREAKPOINTS ==========
  /// Breakpoint cho mobile
  static const double mobileBreakpoint = 600.0;

  /// Breakpoint cho tablet
  static const double tabletBreakpoint = 900.0;

  /// Breakpoint cho desktop
  static const double desktopBreakpoint = 1200.0;

  // ========== HELPER METHODS ==========
  /// Lấy padding theo screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < mobileBreakpoint) {
      return const EdgeInsets.all(smallPadding);
    } else if (screenWidth < tabletBreakpoint) {
      return const EdgeInsets.all(mainPadding);
    } else {
      return const EdgeInsets.all(largePadding);
    }
  }

  /// Lấy font size theo screen size
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < mobileBreakpoint) {
      return baseFontSize * 0.9;
    } else if (screenWidth > desktopBreakpoint) {
      return baseFontSize * 1.1;
    }
    return baseFontSize;
  }

  /// Kiểm tra có phải mobile không
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Kiểm tra có phải tablet không
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Kiểm tra có phải desktop không
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
}
